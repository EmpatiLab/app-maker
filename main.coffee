express = require('express')
app = express()
http = require('http').Server(app)
nedb = require 'nedb'
session = require 'express-session'
users = new nedb { filename: "DB/users.json",autoload:true }
projects = new nedb { filename: "DB/projects.json",autoload:true }
pages = new nedb { filename: "DB/pages.json",autoload:true }
bodyParser = require 'body-parser'
app.use '/',express.static __dirname + '/'
app.use session {secret: '1234567890QWERTY'}
app.use bodyParser.json()
app.use bodyParser.urlencoded {extended: true}

app.post '/login', (req,res) =>
    users.findOne {mail:req.body.mail,password:req.body.password},(err,resd)=>
      if err? then res.send 'kullanıcı bulunamadı'
      else
          req.session.mail = req.body.mail
          req.session.user = resd._id
          res.redirect '/welcome'


app.post '/register', (req,res)=>
  users.insert {mail:req.body.mail,password:req.body.password}
  res.redirect '/login'

app.get '/login',(req,res)=>
  if req.session.user? then res.redirect '/welcome'
  else res.sendFile '/login.html', { root: __dirname }

app.get '/register',(req,res)=>
  res.sendFile '/register.html', { root: __dirname }

app.get '/welcome',(req,res)=>
  if req.session.user? then res.sendFile '/welcome.html', { root: __dirname }
  else res.redirect '/login'

app.get '/IDE/:project',(req,res)=>
  p = req.params.project
  if req.session.user? then res.sendFile '/ide.html', { root: __dirname }
  else res.redirect '/login'

app.get '/userdata', (req,res)=>
  DB.findOne {_id:req.session.user}, (err,resd)=>
    delete resd.password
    res.send resd || err

app.get '/projectlist',(req,res)=>
  projects.find {whose:req.session.user},(err,resd)=>
    res.send resd || err

app.post '/project',(req,res) =>
  if req.session.user? then projects.findOne { _id: req.body.id, whose:req.session.user },(err,resd) =>
    res.send resd || err

app.post '/project/create',(req,res)=>
  if req.session.user? then projects.insert {name:req.body.projectname,whose:req.session.user,pages:{}} , (err,resd)=>
    res.send resd._id

app.post '/project/delete',(req,res)=>
  if req.session.user? then projects.remove { _id: req.body.id }, {}, (err, numRemoved) =>
    res.send req.body.id


app.post '/page', (req,res) =>
    if req.session.user?
      pages.findOne {_id:req.body.p},(err,resd)=>
        if resd? and resd.body? then res.send resd.body
        else  res.send "Not Found"

app.post '/page/new', (req,res) =>
   if req.session.user?
     pages.insert req.body.pagedata, (err,r)=>
       obj = {}
       obj["pages."+req.body.pagedata.page] = r._id
       projects.update {_id:req.body.id},{$set: obj}, (err,resd) =>
         res.send "Done"


http.listen 80, => console.log "Server Started."

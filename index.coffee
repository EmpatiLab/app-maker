currenttab = 0
tabs = []
elementids = [];
opentab = (tabtitle,name) =>
  if name in tabs then changetab name
  else
    $.get 'tab.'+name+'.html', (data)=>
      $('#leftp').css('display','none')
      $('#rightp').css('display','none')
      $('#tabss').append("""
      <button id="btn#{name}" type="button" onclick="changetab('#{name}')" class="btn btn-default">
      #{tabtitle} <a onclick="closetab('#{name}')">x</a>
      </button>
      """)
      tab = $("<div>",{id:'tab'+name}).html(data)
      $('#'+tabs[currenttab]).css('display','none')
      tabs.push(name)
      currenttab = tabs.indexOf(name)
      $('#tabw').append(tab)
      $('#center').attr("class","col-md-12")

changetab = (name)=>
  $('#tab'+tabs[currenttab]).css('display','none')
  $('#tab'+name).css('display','block')
  currenttab = tabs.indexOf(name)
  if $('#tab'+name).attr('designer') is 'true'
    $('#center').attr("class","col-md-8")
    $('#leftp').css('display','block')
    $('#rightp').css('display','block')
  else if currenttab is -1
    $('#center').attr("class","col-md-8")
    $('#leftp').css('display','block')
    $('#rightp').css('display','none')
  else
    $('#center').attr("class","col-md-12")
    $('#leftp').css('display','none')
    $('#rightp').css('display','none')
closetab = (name)=>
  $('#tab'+name).remove()
  $('#btn'+name).remove()
  if tabs[currenttab] is name then changetab tabs[currenttab - (currenttab > 1 ? 1 : -1)]
  tabs.splice(tabs.indexOf(name),1)
opendesigner = (pagetitle,page)=>
  $.post '/page',{'p': page},(data)=>
    $('#center').attr("class","col-md-8")
    $('#leftp').css('display','block')
    $('#rightp').css('display','block')
    $('#tab'+tabs[currenttab]).css('display','none')
    tabs.push(page)
    currenttab = tabs.length
    $('#tabss').append("""
    <button id="btn#{page}" type="button" onclick="changetab('#{page}')" class="btn btn-default">
    #{pagetitle} <a onclick="closetab('#{page}')">x</a>
    </button>
    """)
    designer = $("<itemdrop-element>").html(data)
    designer.attr('designer','true')
    designer.attr('id','drp'+page)
    $('#tabw').append(designer)
    #observer.observe designer, {childList:true}

createpage = =>
  pagename = prompt "Sayfa Adını Girin"
  if pagename? then $.post '/page/new', {pagedata:{page:pagename,body:'<html></html>'},id:pID}
  rData()

openprew = (pagetitle,page)=>
  $.get '/page?p=#{page}', (data)=>
    $('#leftp').css('display','none')
    $('#rightp').css('display','none')
    $('#tabss').append("""
    <button id="btn#{page}" type="button" onclick="changetab('#{page}')" class="btn btn-default">
    #{pagetitle} <a onclick="closetab('#{page}')">x</a>
    </button>
    """)
    tab = $("<div>",{id:"tab"+page}).html(data)
    $('#tab'+tabs[currenttab]).css('display','none')
    tabs.push(page)
    currenttab = tabs.length
    $('#tabw').append(tab)
    $('#center').attr("class","col-md-12")

-- Beatball Modified by Tortuggue | Delta móvil | interfaz local
local Players=game:GetService('Players')
local Workspace=game:GetService('Workspace')
local Lighting=game:GetService('Lighting')
local UIS=game:GetService('UserInputService')
local HttpService=game:GetService('HttpService')
local player=Players.LocalPlayer
local pg=player:WaitForChild('PlayerGui')
-- Quita pruebas anteriores antes de capturar originales nuevos.
for _,key in ipairs({'Zapia2DWorldSafeCleanup','Zapia2DWorldCleanup','ZapiaBeatballCleanup','ZapiaFPSBoosterCleanup','TortuggueHubCleanup'}) do
 if type(_G[key])=='function' then pcall(_G[key]) end
end
local alive=true
local boost=false
local expanded=false
local infoOpen=false
local busy=false
local run=0
local originals={}
local watched={}
local links={}
local created={}
local green=Color3.fromRGB(37,143,55)
local settingsFile='TortuggueBeatball/settings_v1.json'
local prefs={boost=false,cap=0}
local function ensureFolder()
 if type(makefolder)=='function' and type(isfolder)=='function' then
  if not isfolder('TortuggueBeatball') then pcall(makefolder,'TortuggueBeatball') end
 end
end
local function loadPrefs()
 if type(readfile)~='function' then return end
 local ok,text=pcall(readfile,settingsFile)
 if not ok then return end
 local valid,data=pcall(function()return HttpService:JSONDecode(text)end)
 if valid and type(data)=='table' then
  prefs.boost=data.boost==true
  prefs.cap=type(data.cap)=='number' and math.clamp(math.floor(data.cap),0,3) or 0
 end
end
loadPrefs()
local capFn=type(setfpscap)=='function' and setfpscap or nil
local capIndex=prefs.cap
local capLabels={'30','60','SIN LÍMITE'}
local capValues={30,60,0}
local capPrevious=nil
if type(getfpscap)=='function' then
 local ok,value=pcall(getfpscap)
 if ok and type(value)=='number' then capPrevious=value end
end
local function listen(signal,callback)
 local c=signal:Connect(callback)
 table.insert(links,c)
 return c
end
local function set(o,p,v)
 local ok,prev=pcall(function()return o[p]end)
 if not ok or prev==v then return false end
 local slot=originals[o]
 if not slot then slot={};originals[o]=slot end
 if slot[p]==nil then slot[p]=prev end
 local success=pcall(function()o[p]=v end)
 if not success and next(slot)==nil then originals[o]=nil end
 return success
end
local function restore()
 for o,props in pairs(originals) do
  for p,v in pairs(props) do pcall(function()o[p]=v end) end
 end
 table.clear(originals)
end
local function inProtectedArt(o)
 local node=o
 while node and node~=Workspace do
  if node:IsA('ImageLabel') or node:IsA('ImageButton') or node:IsA('TextLabel') or node:IsA('TextButton') then return true end
  node=node.Parent
 end
 return false
end
local function isEntity(o)
 local node=o
 while node and node~=Workspace do
  local n=node.Name:lower()
  for _,w in ipairs({'ball','balon','pelota','player','character','avatar','goal','porteria'}) do
   if n:find(w,1,true) then return true end
  end
  node=node.Parent
 end
 return false
end
local function applyWorld(o)
 if inProtectedArt(o) or isEntity(o) then return end
 if o:IsA('BasePart') then
  set(o,'Material',Enum.Material.Plastic)
  set(o,'Color',green)
  set(o,'CastShadow',false)
 elseif o:IsA('Frame') then
  if o.BackgroundTransparency<0.99 then set(o,'BackgroundColor3',green) end
 elseif o:IsA('UIStroke') or o:IsA('UIGradient') then
  if o.Parent and o.Parent:IsA('Frame') then set(o,'Enabled',false) end
 elseif o:IsA('Decal') or o:IsA('Texture') then
  set(o,'Transparency',1)
 end
end
local function applyStroke(o)
 -- Solo contornos: nunca borra rellenos ni cambia colores de sprites.
 if o:IsA('UIStroke') and o.Enabled then set(o,'Enabled',false) end
end
local function applyLighting(o)
 if o:IsA('PostEffect') then set(o,'Enabled',false)
 elseif o:IsA('ParticleEmitter') or o:IsA('Trail') or o:IsA('Beam') or o:IsA('Smoke') or o:IsA('Fire') or o:IsA('Sparkles') then
  set(o,'Enabled',false)
 elseif o:IsA('PointLight') or o:IsA('SpotLight') or o:IsA('SurfaceLight') then
  set(o,'Enabled',false)
 end
end
local function apply(o)
 if not alive or not boost then return end
 local root=Workspace:FindFirstChild('_2DWorld')
 if root and (o==root or o:IsDescendantOf(root)) then
  applyWorld(o)
  applyStroke(o)
 end
 if o==Lighting or o:IsDescendantOf(Lighting) then applyLighting(o) end
end
local function mk(class,props,parent)
 local o=Instance.new(class)
 for k,v in pairs(props) do o[k]=v end
 o.Parent=parent
 table.insert(created,o)
 return o
end
local bg=Color3.fromRGB(21,22,26)
local surface=Color3.fromRGB(30,31,36)
local line=Color3.fromRGB(55,56,63)
local red=Color3.fromRGB(185,44,55)
local white=Color3.fromRGB(237,238,241)
local muted=Color3.fromRGB(163,166,175)
local gui=mk('ScreenGui',{Name='TortuggueHub',ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=9000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},pg)
local orb=mk('TextButton',{Name='Turtle',Size=UDim2.fromOffset(54,54),Position=UDim2.new(0,10,0.42,0),BackgroundColor3=bg,Text='🐢',TextSize=27,TextColor3=white,Font=Enum.Font.GothamBold,AutoButtonColor=true,ZIndex=10},gui)
mk('UICorner',{CornerRadius=UDim.new(1,0)},orb)
mk('UIStroke',{Color=red,Thickness=1.5,Transparency=0.1},orb)
local hub=mk('Frame',{Name='Window',Size=UDim2.fromOffset(350,250),Position=UDim2.new(0.5,-175,0.5,-125),BackgroundColor3=bg,Visible=false,ZIndex=10},gui)
mk('UICorner',{CornerRadius=UDim.new(0,12)},hub)
mk('UIStroke',{Color=line,Thickness=1},hub)
local titlebar=mk('Frame',{Name='DragTitle',Size=UDim2.new(1,0,0,42),BackgroundColor3=surface,BorderSizePixel=0,Active=true,ZIndex=11},hub)
mk('UICorner',{CornerRadius=UDim.new(0,12)},titlebar)
mk('Frame',{Size=UDim2.new(1,0,0,11),Position=UDim2.new(0,0,1,-11),BackgroundColor3=surface,BorderSizePixel=0,ZIndex=11},titlebar)
mk('TextLabel',{Size=UDim2.new(1,-90,1,0),Position=UDim2.fromOffset(11,0),BackgroundTransparency=1,Text='Beatball Modified by Tortuggue',TextXAlignment=Enum.TextXAlignment.Left,TextColor3=white,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=12},titlebar)
local minimize=mk('TextButton',{Size=UDim2.fromOffset(35,31),Position=UDim2.new(1,-39,0,5),BackgroundColor3=Color3.fromRGB(55,39,44),Text='−',TextSize=22,TextColor3=white,Font=Enum.Font.GothamBold,ZIndex=13},titlebar)
mk('UICorner',{CornerRadius=UDim.new(0,7)},minimize)
local settings=mk('TextButton',{Size=UDim2.fromOffset(35,31),Position=UDim2.new(1,-78,0,5),BackgroundColor3=Color3.fromRGB(43,43,50),Text='⚙',TextSize=19,TextColor3=white,Font=Enum.Font.GothamBold,ZIndex=13},titlebar)
mk('UICorner',{CornerRadius=UDim.new(0,7)},settings)
mk('Frame',{Size=UDim2.new(1,0,0,1),Position=UDim2.fromOffset(0,42),BackgroundColor3=line,BorderSizePixel=0,ZIndex=11},hub)
local sidebar=mk('Frame',{Size=UDim2.fromOffset(90,177),Position=UDim2.fromOffset(0,43),BackgroundColor3=Color3.fromRGB(25,26,31),BorderSizePixel=0,ZIndex=11},hub)
mk('Frame',{Size=UDim2.fromOffset(1,177),Position=UDim2.new(1,-1,0,0),BackgroundColor3=line,BorderSizePixel=0,ZIndex=12},sidebar)
local boosterNav=mk('TextButton',{Size=UDim2.fromOffset(80,36),Position=UDim2.fromOffset(5,9),BackgroundColor3=Color3.fromRGB(61,35,42),Text='Booster',TextColor3=white,TextSize=13,Font=Enum.Font.GothamSemibold,ZIndex=12},sidebar)
mk('UICorner',{CornerRadius=UDim.new(0,7)},boosterNav)
mk('Frame',{Size=UDim2.fromOffset(2,25),Position=UDim2.fromOffset(1,5),BackgroundColor3=red,BorderSizePixel=0,ZIndex=13},boosterNav)
local content=mk('Frame',{Size=UDim2.new(1,-100,0,172),Position=UDim2.fromOffset(96,48),BackgroundTransparency=1,ZIndex=11},hub)
local section=mk('TextLabel',{Size=UDim2.new(1,-5,0,20),BackgroundTransparency=1,Text='RENDIMIENTO VISUAL',TextXAlignment=Enum.TextXAlignment.Left,TextColor3=muted,TextSize=10,Font=Enum.Font.GothamBold,ZIndex=12},content)
local row=mk('TextButton',{Size=UDim2.new(1,-6,0,39),Position=UDim2.fromOffset(0,23),BackgroundColor3=surface,Text='  FPSBooster                 ›',TextXAlignment=Enum.TextXAlignment.Left,TextColor3=white,TextSize=12,Font=Enum.Font.GothamSemibold,ZIndex=12},content)
mk('UICorner',{CornerRadius=UDim.new(0,7)},row)
local detail=mk('Frame',{Size=UDim2.new(1,-6,0,105),Position=UDim2.fromOffset(0,66),BackgroundTransparency=1,Visible=false,ZIndex=12},content)
local boostButton=mk('TextButton',{Size=UDim2.fromOffset(172,35),Position=UDim2.fromOffset(0,0),BackgroundColor3=surface,Text='Simplificar: OFF',TextColor3=white,TextSize=12,Font=Enum.Font.GothamSemibold,ZIndex=13},detail)
mk('UICorner',{CornerRadius=UDim.new(0,6)},boostButton)
local help1=mk('TextButton',{Size=UDim2.fromOffset(34,35),Position=UDim2.fromOffset(177,0),BackgroundColor3=surface,Text='¡',TextColor3=red,TextSize=19,Font=Enum.Font.GothamBold,ZIndex=13},detail)
mk('UICorner',{CornerRadius=UDim.new(0,6)},help1)
local capButton=mk('TextButton',{Size=UDim2.fromOffset(172,35),Position=UDim2.fromOffset(0,40),BackgroundColor3=surface,Text='FPS cap: sin cambios',TextColor3=white,TextSize=11,Font=Enum.Font.GothamSemibold,ZIndex=13},detail)
mk('UICorner',{CornerRadius=UDim.new(0,6)},capButton)
local help2=mk('TextButton',{Size=UDim2.fromOffset(34,35),Position=UDim2.fromOffset(177,40),BackgroundColor3=surface,Text='¡',TextColor3=red,TextSize=19,Font=Enum.Font.GothamBold,ZIndex=13},detail)
mk('UICorner',{CornerRadius=UDim.new(0,6)},help2)
local note=mk('TextLabel',{Size=UDim2.fromOffset(214,28),Position=UDim2.fromOffset(0,78),BackgroundTransparency=1,Text='Solo visual: no promete +FPS.',TextColor3=muted,TextSize=10,TextWrapped=true,Font=Enum.Font.Gotham,ZIndex=13},detail)
local footer=mk('Frame',{Size=UDim2.new(1,0,0,29),Position=UDim2.new(0,0,1,-29),BackgroundColor3=surface,BorderSizePixel=0,ZIndex=11},hub)
mk('UICorner',{CornerRadius=UDim.new(0,12)},footer)
mk('Frame',{Size=UDim2.new(1,0,0,12),BackgroundColor3=surface,BorderSizePixel=0,ZIndex=11},footer)
mk('Frame',{Size=UDim2.new(1,0,0,1),BackgroundColor3=line,BorderSizePixel=0,ZIndex=12},footer)
local credit=mk('TextLabel',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text='By Tortuggue',TextColor3=red,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=12},footer)
local modal=mk('Frame',{Size=UDim2.fromOffset(318,151),Position=UDim2.new(0.5,-159,0.5,-75),BackgroundColor3=Color3.fromRGB(32,33,39),Visible=false,ZIndex=30},hub)
mk('UICorner',{CornerRadius=UDim.new(0,10)},modal)
mk('UIStroke',{Color=red,Thickness=1},modal)
local modalText=mk('TextLabel',{Size=UDim2.fromOffset(294,104),Position=UDim2.fromOffset(12,7),BackgroundTransparency=1,TextColor3=white,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextSize=12,Font=Enum.Font.Gotham,ZIndex=31},modal)
local close=mk('TextButton',{Size=UDim2.fromOffset(92,31),Position=UDim2.new(0.5,-46,1,-37),BackgroundColor3=Color3.fromRGB(105,38,49),Text='Cerrar',TextColor3=white,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=31},modal)
mk('UICorner',{CornerRadius=UDim.new(0,6)},close)

local settingsPane=mk('Frame',{Size=UDim2.fromOffset(318,151),Position=UDim2.new(0.5,-159,0.5,-75),BackgroundColor3=Color3.fromRGB(32,33,39),Visible=false,ZIndex=28},hub)
mk('UICorner',{CornerRadius=UDim.new(0,10)},settingsPane)
mk('UIStroke',{Color=red,Thickness=1},settingsPane)
local settingsTitle=mk('TextLabel',{Size=UDim2.fromOffset(230,23),Position=UDim2.fromOffset(10,5),BackgroundTransparency=1,Text='AJUSTES',TextXAlignment=Enum.TextXAlignment.Left,TextColor3=white,TextSize=13,Font=Enum.Font.GothamBold,ZIndex=29},settingsPane)
local settingsClose=mk('TextButton',{Size=UDim2.fromOffset(30,26),Position=UDim2.fromOffset(280,5),BackgroundColor3=surface,Text='×',TextSize=21,TextColor3=white,ZIndex=29},settingsPane)
local saveBtn=mk('TextButton',{Size=UDim2.fromOffset(298,39),Position=UDim2.fromOffset(10,36),BackgroundColor3=Color3.fromRGB(79,36,46),Text='GUARDAR',TextSize=13,TextColor3=white,Font=Enum.Font.GothamBold,ZIndex=29},settingsPane)
local settingsStatus=mk('TextLabel',{Size=UDim2.fromOffset(296,65),Position=UDim2.fromOffset(11,80),BackgroundTransparency=1,Text='Guardar conserva Simplificar y FPS cap para la próxima ejecución.',TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=muted,TextSize=11,Font=Enum.Font.Gotham,ZIndex=29},settingsPane)
local function persist()
 if type(writefile)~='function' then return false,'Delta no permite guardar archivos.' end
 ensureFolder()
 local ok,err=pcall(writefile,settingsFile,HttpService:JSONEncode(prefs))
 return ok,err
end
listen(settings.MouseButton1Click,function()
 modal.Visible=false;settingsPane.Visible=not settingsPane.Visible
end)
listen(settingsClose.MouseButton1Click,function()settingsPane.Visible=false end)
listen(saveBtn.MouseButton1Click,function()
 prefs.boost=boost;prefs.cap=capIndex
 local ok,err=persist()
 settingsStatus.Text=ok and 'Opciones guardadas en Delta.' or tostring(err)
end)
local function showHelp(text)modalText.Text=text;modal.Visible=true end
listen(help1.MouseButton1Click,function()
 showHelp('Simplificar: vuelve verde y plástico el mundo 2D, reduce efectos y quita contornos sin borrar el relleno del balón ni jugador. Cambio local y reversible. No garantiza más FPS.')
end)
listen(help2.MouseButton1Click,function()
 showHelp('FPS cap: cambia 30, 60 o sin límite SOLO si Delta ofrece setfpscap. Sin límite no fuerza al teléfono a superar su pantalla o potencia. Al cerrar el HUB intenta restaurar el límite previo si se puede leer.')
end)
listen(close.MouseButton1Click,function()modal.Visible=false end)
listen(boosterNav.MouseButton1Click,function()modal.Visible=false;settingsPane.Visible=false end)
listen(row.MouseButton1Click,function()
 expanded=not expanded;detail.Visible=expanded
 row.Text=expanded and '  FPSBooster                 ⌄' or '  FPSBooster                 ›'
end)
local function doBoost()
 local root=Workspace:FindFirstChild('_2DWorld')
 if root then
  local count=0
  for _,o in ipairs(root:GetDescendants()) do
   if not alive or not boost then return end
   apply(o);count+=1;if count%140==0 then task.wait() end
  end
 else
  note.Text='No se halló _2DWorld; campo sin cambiar.'
 end
 if not alive or not boost then return end
 set(Lighting,'GlobalShadows',false)
 for _,o in ipairs(Lighting:GetDescendants()) do applyLighting(o) end
 if root and not watched[root] then
  watched[root]=true
  listen(root.DescendantAdded,function(o)
   if boost and alive then task.defer(function()if boost and alive then apply(o)end end)end
  end)
 end
 if not watched[Lighting] then
  watched[Lighting]=true
  listen(Lighting.DescendantAdded,function(o)
   if boost and alive then task.defer(function()if boost and alive then applyLighting(o)end end)end
  end)
 end
 note.Text=root and 'Campo y efectos simplificados.' or note.Text
end
listen(boostButton.MouseButton1Click,function()
 if busy then return end
 if boost then
  boost=false;run+=1;restore()
  boostButton.Text='Simplificar: OFF';boostButton.BackgroundColor3=surface
  note.Text='Restaurado.'
 else
  boost=true;run+=1;busy=true
  boostButton.Text='Simplificar: ON';boostButton.BackgroundColor3=Color3.fromRGB(71,34,43)
  note.Text='Aplicando...'
  task.spawn(function()doBoost();busy=false end)
 end
end)
listen(capButton.MouseButton1Click,function()
 if not capFn then capButton.Text='FPS cap: no disponible';return end
 local nextIndex=capIndex%3+1
 local ok=pcall(capFn,capValues[nextIndex])
 if ok then
  capIndex=nextIndex;capButton.Text='FPS cap: '..capLabels[capIndex]
 else capFn=nil;capButton.Text='FPS cap: no disponible' end
end)
if not capFn then capButton.Text='FPS cap: no disponible'
elseif capIndex>0 then
 local ok=pcall(capFn,capValues[capIndex])
 if ok then capButton.Text='FPS cap: '..capLabels[capIndex] else capIndex=0;capButton.Text='FPS cap: no disponible' end
end
-- Arrastre táctil de la bolita y de la barra del título.
local function drag(handle,target,click)
 local dragging=false;local pointer;local start;local origin;local moved=false
 listen(handle.InputBegan,function(input)
  if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
  dragging=true;pointer=input;start=input.Position;origin=target.Position;moved=false
  local endConn;endConn=input.Changed:Connect(function()
   if input.UserInputState==Enum.UserInputState.End then dragging=false;endConn:Disconnect() end
  end)
 end)
 listen(UIS.InputChanged,function(input)
  if not dragging or not start or not origin then return end
  if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
  if input.UserInputType==Enum.UserInputType.Touch and input~=pointer then return end
  local d=input.Position-start
  if d.Magnitude>8 then moved=true end
  if moved then target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y) end
 end)
 if click then
  listen(handle.InputEnded,function(input)
   if input==pointer and not moved then click() end
  end)
 end
end
-- InputEnded puede ocurrir después de Changed; el clic de la bolita usa MouseButton1Click.
drag(orb,orb,nil)
drag(titlebar,hub,nil)
listen(orb.MouseButton1Click,function()orb.Visible=false;hub.Visible=true end)
listen(minimize.MouseButton1Click,function()modal.Visible=false;settingsPane.Visible=false;hub.Visible=false;orb.Visible=true end)
-- RGB lento (6 Hz), solo texto del crédito.
local elapsed=0
listen(game:GetService('RunService').Heartbeat,function(dt)
 if not alive or not hub.Visible then return end
 elapsed+=dt
 if elapsed>=0.16 then
  elapsed=0
  local h=(os.clock()*0.12)%1
  credit.TextColor3=Color3.fromHSV(h,0.53,0.94)
 end
end)
if prefs.boost then
 boost=true;busy=true;boostButton.Text='Simplificar: ON';boostButton.BackgroundColor3=Color3.fromRGB(71,34,43)
 task.spawn(function()doBoost();busy=false end)
end
_G.TortuggueHubCleanup=function()
 alive=false;boost=false;restore()
 if capPrevious and type(setfpscap)=='function' then pcall(setfpscap,capPrevious) end
 for _,c in ipairs(links) do pcall(function()c:Disconnect()end) end
 gui:Destroy();_G.TortuggueHubCleanup=nil
end

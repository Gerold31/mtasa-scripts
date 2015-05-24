local LabelID = {}
LabelAll = 0

addEvent("doCreateLabel", true)
addEventHandler("doCreateLabel", root, function(text, color, x, y, z, dis, dimens, font, size) create3DTextLabel(text, color, x, y, z, dis, dimens, font, size) end)

addEvent("doRemoveLabel", true)
addEventHandler("doRemoveLabel", root, function(id) delete3DTextLabel(id) end)

addEvent("doUpdateLabel", true)
addEventHandler("doUpdateLabel", root, function(i, t, c, x, y, z, d, f, g, s) update3DTextLabel(i, t, c, x, y, z, d, f, g, s) end)

addEvent("doAttachLabel", true)
addEventHandler("doAttachLabel", root, function(i, e, x, y, z, d) attach3DTextLabelToElement(i, e, x, y, z, d) end)

addEvent("doDetachLabel", true)
addEventHandler("doDetachLabel", root, function(i) detach3DTextLabel(i) end)

function create3DTextLabel(text, color, x, y, z, dis, dimens, font, size) --def 150
    if not text then return false end
    if not color then color = tocolor(255, 255, 255, 255) end 
    if not x or x == "x" then x = getElementPosition(localPlayer) end
    if not y or y == "x" then _, y = getElementPosition(localPlayer) end
    if not z or z == "x" then _, _, z = getElementPosition(localPlayer) end
    if not dis or not tonumber(dis) then dis = 150 end
    if not dimens or not tonumber(dimens) then dimens = -1 end
    if not font then font = "default-bold" end
    if not size or not tonumber(size) or tonumber(size) <= 0 then size = 1 end
    
    --LabelAll = id
    LabelAll = LabelAll + 1       
    
    color = string.format("%x", color)
    local alpha = string.sub(color, 1, 2)
    color = "0x"..color
    
    LabelID[LabelAll] = {}
    LabelID[LabelAll]["PosX"] = tonumber(x)
    LabelID[LabelAll]["PosY"] = tonumber(y)
    LabelID[LabelAll]["PosZ"] = tonumber(z)
    LabelID[LabelAll]["Text"] = text
    LabelID[LabelAll]["Dist"] = tonumber(dis)
    LabelID[LabelAll]["Colr"] = tonumber(color)
    LabelID[LabelAll]["Alph"] = tostring(alpha)
    LabelID[LabelAll]["Enbl"] = true
    LabelID[LabelAll]["Dimn"] = tonumber(dimens)
    LabelID[LabelAll]["BDim"] = false
    LabelID[LabelAll]["Attc"] = false
    LabelID[LabelAll]["AttX"] = 0
    LabelID[LabelAll]["AttY"] = 0
    LabelID[LabelAll]["AttZ"] = 0
    LabelID[LabelAll]["Font"] = font
    LabelID[LabelAll]["Size"] = tonumber(size)
    
    if LabelID[LabelAll]["Dimn"] and LabelID[LabelAll]["Dimn"] >= 0 then LabelID[LabelAll]["BDim"] = true end
    
    showLabel(LabelAll)    
    
    triggerServerEvent("addLabels", root, LabelAll)
    
    return LabelAll
end
function delete3DTextLabel(id)
    if not LabelID[id] then return false end
    LabelID[id]["Enbl"] = false
end
function update3DTextLabel(id, text, color, x, y, z, dist, dimens, font, size)
    if not LabelID[id] then return false end
    if not text then return false end
    if not color then color = LabelID[id]["Colr"] end
    if not x or not tonumber(x) then x = LabelID[id]["PosX"] end
    if not y or not tonumber(y) then y = LabelID[id]["PosY"] end
    if not z or not tonumber(z) then z = LabelID[id]["PosZ"] end
    if not dist or not tonumber(dist) then dist = LabelID[id]["Dist"] end
    if not dimens or not tonumber(dimens) then dimens = LabelID[LabelAll]["Dimn"] end
    if not font then font = LabelID[id]["Font"] end
    if not size or not tonumber(size) or tonumber(size) <= 0 then size = LabelID[LabelAll]["Size"] end
    
    color = string.format("%x", color)
    local alpha = string.sub(color, 1, 2)
    color = "0x"..color
    
    LabelID[id]["Text"] = text
    LabelID[id]["Colr"] = tonumber(color)
    LabelID[id]["Alph"] = tostring(alpha)
    LabelID[id]["PosX"] = x
    LabelID[id]["PosY"] = y
    LabelID[id]["PosZ"] = z
    LabelID[id]["Dist"] = tonumber(dist)
    LabelID[id]["Dimn"] = tonumber(dimens)
    LabelID[id]["BDim"] = false
    LabelID[id]["Font"] = font
    LabelID[id]["Size"] = tonumber(size)
    if LabelID[id]["Dimn"] and LabelID[id]["Dimn"] >= 0 then LabelID[id]["BDim"] = true end
end

function attach3DTextLabelToElement(id, element, x, y, z, dimens)
    if not LabelID[id] then return false end
    if not isElement(element) then return false end
    if not x or not tonumber(x) then x = 0 end
    if not y or not tonumber(y) then y = 0 end
    if not z or not tonumber(z) then z = 0 end
    if not dimens or not tonumber(dimens) then dimens = -1 end
    LabelID[id]["Attc"] = element
    LabelID[id]["AttX"] = tonumber(x)
    LabelID[id]["AttY"] = tonumber(y)
    LabelID[id]["AttZ"] = tonumber(z)
    LabelID[id]["Dimn"] = tonumber(dimens)
    LabelID[id]["BDim"] = false
    if LabelID[id]["Dimn"] and LabelID[id]["Dimn"] >= 0 then LabelID[id]["BDim"] = true end
end

function detach3DTextLabel(id)
    if not LabelID[id] then return false end
    LabelID[id]["Attc"] = false
end
    
function labelFunction(id, x, y, z, text, dis, color, alpha, font, size)
    if not LabelID[id] then return nil end

    local NewX,NewY,NewZ = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(x,y,z,NewX,NewY,NewZ)
    if distance <= dis then
        local ScX,ScY = getScreenFromWorldPosition(x, y, z+0.95, 0.06)
        if not ScX then return end
        dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), ScX+2, ScY-30+2, ScX, ScY-30, tonumber("0x"..alpha.."000000"), math.min(0.3*(dis/distance)*1.4*size,size), font, "center", "bottom", false, false, false)
        dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), ScX-2, ScY-30+2, ScX, ScY-30, tonumber("0x"..alpha.."000000"), math.min(0.3*(dis/distance)*1.4*size,size), font, "center", "bottom", false, false, false)
        dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), ScX+2, ScY-30-2, ScX, ScY-30, tonumber("0x"..alpha.."000000"), math.min(0.3*(dis/distance)*1.4*size,size), font, "center", "bottom", false, false, false)
        dxDrawText(text:gsub("#%x%x%x%x%x%x", ""), ScX-2, ScY-30-2, ScX, ScY-30, tonumber("0x"..alpha.."000000"), math.min(0.3*(dis/distance)*1.4*size,size), font, "center", "bottom", false, false, false)
        dxDrawText(text, ScX, ScY-30, ScX, ScY-30, color, math.min(0.3*(dis/distance)*1.4*size,size), font, "center", "bottom", false, false, false, true)
    end
end

function showLabel(id)
    if not LabelID[id] then return nil end
    addEventHandler("onClientRender",getRootElement(),
        function()
            if LabelID[id]["BDim"] then if getElementDimension(localPlayer) ~= LabelID[id]["Dimn"] then return 1; end end
            if not LabelID[id]["Enbl"] then cancelEvent() return 1; end
            if LabelID[id]["Attc"] ~= false then 
                if not isElement(LabelID[id]["Attc"]) then LabelID[id]["Attc"] = false return 1; end
                local nx, ny, nz = getElementPosition(LabelID[id]["Attc"])
                LabelID[id]["PosX"] = nx+LabelID[id]["AttX"]
                LabelID[id]["PosY"] = ny+LabelID[id]["AttY"]
                LabelID[id]["PosZ"] = nz+LabelID[id]["AttZ"]
            end
            labelFunction(id, LabelID[id]["PosX"], LabelID[id]["PosY"], LabelID[id]["PosZ"], LabelID[id]["Text"], LabelID[id]["Dist"], LabelID[id]["Colr"], LabelID[id]["Alph"], LabelID[id]["Font"], LabelID[id]["Size"])
        end)
end

--[[addEventHandler("onClientResourceStart", root,
    function()
        label = create3DTextLabel("Lost", 0xFFFFFF00, 0, 0, 10, 700, 0)
        labels = create3DTextLabel("test", 0xFFFFF000, 0, 0, 15, 700, 0)
        labelz = create3DTextLabel("Fest", 0xFFFFF000, 0, 0, 20, 700, 0)
        attach3DTextLabelToElement(label, localPlayer or getPedOccupiedVehicle(localPlayer))
        setTimer(function()
            local vx, vy, vz = getElementPosition(localPlayer or getPedOccupiedVehicle(localPlayer))
            update3DTextLabel(label, "#FF0000X: #FFFFFF"..string.format("%.4f", vx).."\n#FF0000Y: #FFFFFF"..string.format("%.4f", vy).."\n#FF0000Z: #FFFFFF"..string.format("%.4f", vz))
        end, 50, 1000)
        setTimer(function()
            detach3DTextLabel(label)
        end, 52*1000, 1)
        end)]]

    

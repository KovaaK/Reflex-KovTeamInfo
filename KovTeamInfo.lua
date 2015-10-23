require "base/internal/ui/reflexcore"

KovTeamInfo =
{
};

local function filter(tbl, func)
    local newtbl= {}
    for i,v in pairs(tbl) do
        if func(v) then
            newtbl[i]=v
        end
    end
    return newtbl
end

local function forEach(tbl, func)
    for key,value in pairs(tbl) do
        func(value, key, tbl)
    end
end

local MAX_PACKET_LOSS = 241

local white = Color(0xff,0xff,0xff)
local lightGrey = Color(0xc0,0xc0,0xc0)
local grey = Color(0x80,0x80,0x80)
local black = Color(0x00,0x00,0x00)
local orange = Color(0xff,0x80,0x00)
local cyan = Color(0x00,0xff,0xff)
local red = Color(0xff,0x00,0x00)
local green = Color(0x00,0xa0,0x00)
local lightOrange = Color(0xff,0xe0,0xc0)
local lightGreen = Color(0xc0,0xff,0xc0)
local darkGrey = Color(0x50,0x50,0x50)

local transparentWhite = Color(0xff,0xff,0xff,0x90)
local transparentBlack = Color(0x00,0x00,0x00,0x90)

local lessTransparentBlack = Color(0x00,0x00,0x00,0xb0)

local transparentRed = Color(0xb0,0x00,0x00,0xb0)
local transparentYellow = Color(0xd0,0xc0,0x00,0xb0)
local transparentGreen = Color(0x00,0xa0,0x00,0xb0)
local transparentDarkRed = Color(0x60,0x05,0x05,0xb0)
local transparentDarkYellow = Color(0x60,0x50,0x0d,0xb0)
local transparentDarkGreen = Color(0x0a,0x40,0x0a,0xb0)
local transparentGrey = Color(0x30,0x30,0x30,0xb0)
local transparentLightBlue = Color(0x00,0x58,0xc0,0xb0)
local transparentCyan = Color(0x00,0xa0,0xa0,0xb0)
local transparentOrange = Color(0xc0,0x60,0x00,0xb0)

local function mainHealthColor(health)
    local lowHealth = 30
    local midHealth = 80
    if health > midHealth then return transparentGreen
    elseif health > lowHealth then return transparentYellow
    else return transparentRed end
end

local trueArmorColor = {}
trueArmorColor[0] = Color(2,167,46, 255)
trueArmorColor[1] = Color(245,215,50, 255)
trueArmorColor[2] = Color(236,0,0, 255)
--trueArmorColor[0] = transparentGreen
--trueArmorColor[1] = transparentYellow
--trueArmorColor[2] = transparentRed

local falseArmorColor = {}
falseArmorColor[0] = transparentDarkGreen
falseArmorColor[1] = transparentDarkYellow
falseArmorColor[2] = transparentDarkRed

local armorColors = {
    Color(0, 255, 0, 255),
    Color(255,255,0,255),
    Color(255,0,0,255)
}

local function fitText(x,y,availableWidth,fontSize,text,drawBackgroundFunction)
    nvgSave()
    nvgFontSize(fontSize)
    local requiredWidth = nvgTextWidth(text)

    if availableWidth then
        while requiredWidth > availableWidth do fontSize = math.floor(fontSize*availableWidth/requiredWidth) nvgFontSize(fontSize) requiredWidth = nvgTextWidth(text) end
        nvgSave()
        if drawBackgroundFunction then drawBackgroundFunction(math.min(requiredWidth,availableWidth)) end
        nvgRestore()
    elseif drawBackgroundFunction then
        nvgSave()
        drawBackgroundFunction(requiredWidth)
        nvgRestore()
    end
    nvgText(x,y,text)
    nvgRestore()
end

local function align(x,y,width,height,alignH,alignV)
    nvgTranslate(x - (alignH == NVG_ALIGN_RIGHT and width or alignH == NVG_ALIGN_CENTER and math.floor(width/2) or 0), y - (alignV == NVG_ALIGN_BOTTOM and height or alignV == NVG_ALIGN_MIDDLE and math.floor(height/2) or 0))
end

local function drawPlayer(player,x,y,alignH,alignV)
    if not player or not player.connected then return end
    local gameOver = (world.gameState == GAME_STATE_GAMEOVER)
    local drawHealth = true
    local fontSize = 2*16
    local fontFace = FONT_HUD
    local margin = 2*4
    local stackMargin = 35
    local nameWidth = 2*84
    local width = margin*4 + nameWidth
    local height = drawHealth and fontSize + margin*3 or fontSize + margin
    local scoreFontSize = drawHealth and math.floor(fontSize*1.5) or math.floor(fontSize*1.25)
    local scoreWidth = 2*math.floor(0.7*scoreFontSize)
    local halfHeight = math.floor(height/2)
    local cameraIntensity = math.min(1,DP2_Scoreboard.cameraIntensity*2)
    local arrowWidth = 2*margin+cameraIntensity*margin
    --local fullWidth = width + margin + scoreWidth + arrowWidth + margin*2
    local fullWidth = width + scoreWidth + (not gameOver and arrowWidth + margin*2 or 0)
    nvgSave()
    align(x,y,fullWidth,height,alignH,alignV)

    if not gameOver then
        nvgTranslate(arrowWidth + margin*2,0)
    end
    if drawHealth and player.health > 0 then
        local mainHealth = math.floor(math.min(100,player.health)*width/200)
        local overHealth = math.floor(math.max(0,player.health-100)*width/200)
        local trueArmor = math.floor(math.min(math.min(math.floor(player.health*(player.armorProtection+1)),200),player.armor)*width/200)
        local trueStack = trueArmor+player.health
        local trueStackBar = math.floor(trueStack*width/400)
        local falseArmor = math.max(0,math.floor(player.armor*width/200)-trueArmor)
        nvgBeginPath()
        nvgRect(0,0,width,height)
        nvgFillColor(transparentBlack)
        nvgScissor(0,margin,width,height-2*margin)
        nvgFill()
        nvgScissor(width/2+overHealth,0,width-mainHealth-overHealth,margin)
        nvgFill()
        nvgScissor(trueArmor+falseArmor,height-margin,width-trueArmor-falseArmor,margin)
        nvgFill()
        nvgScissor(mainHealth,0,width/2-mainHealth,margin)
        nvgFillColor(transparentGrey)
        nvgFill()
        nvgScissor(0,0,mainHealth,margin)
        nvgFillColor(mainHealthColor(mainHealth))
        nvgFill()
        nvgScissor(width/2,0,overHealth,margin)
        nvgFillColor(transparentLightBlue)
        nvgFill()
        nvgScissor(trueArmor,height-margin,falseArmor,margin)
        nvgFillColor(falseArmorColor[player.armorProtection])
        nvgFill()
        nvgScissor(0,height-margin,trueArmor,margin)
        nvgFillColor(trueArmorColor[player.armorProtection])
        nvgFill()
        nvgResetScissor()

        nvgBeginPath()
        nvgRect(0,10,trueStackBar,height-20)
        nvgFillColor(mainHealthColor(mainHealth))
        nvgFill()

        
        nvgFillColor(white)
        nvgFontFace(fontFace)
        nvgFontBlur(0)
        nvgTextAlign(NVG_ALIGN_LEFT,NVG_ALIGN_MIDDLE)
        fitText(margin,halfHeight,nameWidth,fontSize,trueStack)
        
    else
        nvgBeginPath()
        nvgRect(0,0,width,height)
        nvgFillColor(transparentBlack)
        nvgFill()
    end
    --nvgFillColor(getPlayer() == player and cyan or white)
    nvgFillColor(white)
    nvgFontFace(fontFace)
    nvgFontBlur(0)
    nvgTextAlign(NVG_ALIGN_LEFT,NVG_ALIGN_MIDDLE)
    fitText(margin*2+stackMargin,halfHeight,nameWidth-stackMargin,fontSize,player.name)
 
    -- Draw the weapon/ammo
    local svgName = "internal/ui/icons/weapon"..player.weaponIndexSelected;
    nvgTranslate(width,0)
    nvgBeginPath()
    nvgRect(0,10,scoreWidth,height-20)
    nvgFillColor(transparentBlack)
    nvgFill()
    nvgFillColor(player.weapons[player.weaponIndexSelected].color)
    nvgSvg(svgName, scoreWidth/2-16, halfHeight, 16);
    nvgFillColor(white)
    nvgTextAlign(NVG_ALIGN_CENTER,NVG_ALIGN_MIDDLE)
    --fitText(x,y,availableWidth,fontSize,text,drawBackgroundFunction)
    fitText(scoreWidth/2+15,halfHeight,scoreWidth - margin,28,player.weapons[player.weaponIndexSelected].ammo)

    -- Draw Powerups
    local x1 = 80;
    local y = 15

    if player.hasMega then
        nvgFillColor(Color(60,80,255));
        nvgSvg("internal/ui/icons/health", x1, y + 12, 8)
        x1 = x1 + 24;
    end

    if player.hasFlag then
        nvgFillColor(Color(60,80,255));
        nvgSvg("internal/ui/icons/CTFflag", x1, y + 12, 8)
        x1 = x1 + 24;
    end
	
	
    if (player.carnageTimer > 0) then -- player has carnage
        nvgFillColor(Color(255,120,128))
        nvgSvg("internal/ui/icons/carnage", x1, y + 12, 8)
        nvgText(x1 + 8, y, math.ceil(player.carnageTimer / 1000))
        x1 = x1 + 48
    end

    
    nvgRestore()

    nvgTranslate(0,height+margin)
end

function KovTeamInfo:draw()
    -- pull in stored user variables
    local showSelf = self.userData.showSelf
    local showInTeamModes = self.userData.showInTeamModes
    
    -- Early out if HUD should not be shown.
    if not shouldShowHUD() then return end;

    if showInTeamModes then
        local gameMode = gamemodes[world.gameModeIndex].shortName;
        if gameMode ~= 'tdm' and gameMode ~= 'atdm' and gameMode ~= "ctf" then return end;
    end
    
    -- Early out if we are not in (A)TDM

    -- Find player
    local player = getPlayer();

    nvgFontFace(FONT_TEXT);
    nvgFontSize(28);
    nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_TOP);

    local teamPlayers = filter(players, function(p)
        return p.state == PLAYER_STATE_INGAME
            and p.team == player.team
            and p.connected
            and (p ~= player or showSelf == true)
    end)

    -- draw players
    forEach(teamPlayers, function(player, i)
        local y = 32*i;

        drawPlayer(player,0,0,NVG_ALIGN_RIGHT,NVG_ALIGN_TOP)

        --[[
        -- draw armorProtection
        nvgFillColor(armorColors[player.armorProtection + 1]);
        nvgSvg("internal/ui/icons/armor", 0, y + 12, 8)
        -- draw armor
        nvgText(16, y, player.armor)

        -- draw health
        nvgText(64, y, player.health)

        local x1 = 120;

        if player.hasMega then
            nvgFillColor(Color(60,80,255));
            nvgSvg("internal/ui/icons/health", x1, y + 12, 8)
            x1 = x1 + 24;
        end

        if (player.carnageTimer > 0) then -- player has carnage
            nvgFillColor(Color(255,120,128))
            nvgSvg("internal/ui/icons/carnage", x1, y + 12, 8)
            nvgText(x1 + 8, y, math.ceil(player.carnageTimer / 1000))
            x1 = x1 + 48
        end


        -- draw name
        nvgText(x1, y, player.name)

        y = y + 16;

        local j = 0
        forEach(player.weapons, function(weapon, weaponIndex)
            if weaponIndex == 1 -- skip the axe
                or not weapon.pickedup -- skip not picked up weapons
                or weapon.ammo == 0 then -- and empty ones
                return
            end

            nvgFillColor(weapon.color);
            local svgName = "internal/ui/icons/weapon"..weaponIndex;
            nvgSvg(svgName, 64 * j, y + 16, 8);
            nvgText(64 * j + 16, y, weapon.ammo)

            j = j+1
        end)
        --]]
    end)
end


registerWidget("KovTeamInfo");

function KovTeamInfo:initialize()
    -- load data stored in engine
    self.userData = loadUserData();
    -- ensure it has what we need
    CheckSetDefaultValue(self, "userData", "table", {});
    CheckSetDefaultValue(self.userData, "showSelf", "boolean", true);
    CheckSetDefaultValue(self.userData, "showInTeamModes", "boolean", true);
end 

function KovTeamInfo:drawOptions(x, y)
    local user = self.userData;
    user.showSelf = uiCheckBox(user.showSelf, "Show yourself in the list", x, y);
    y = y + 30;

    user.showInTeamModes = uiCheckBox(user.showInTeamModes, "Only Show the widget in Team Modes", x, y);
    y = y + 30;
    
    saveUserData(user);
end

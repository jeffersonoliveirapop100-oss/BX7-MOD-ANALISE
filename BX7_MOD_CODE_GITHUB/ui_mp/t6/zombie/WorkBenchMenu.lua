require("T6.CoDBase")

CoD.WorkBenchMenu = {}
CoD.WorkBenchMenu.ActiveMenu = nil


local function parseWorkbenchItems()
    local activeDvar = UIExpression.DvarString(nil, "ui_workbench_items") or ""
    local activeMap = {}
    local activeCosts = {}

    for entry in string.gmatch(activeDvar, "([^,]+)") do
        local colonPos = string.find(entry, ":")
        if colonPos then
            local code = string.sub(entry, 1, colonPos - 1)
            local cost = tonumber(string.sub(entry, colonPos + 1)) or 0
            activeMap[code] = true
            activeCosts[code] = cost
        else
            activeMap[entry] = true
            activeCosts[entry] = 0
        end
    end

    return activeMap, activeCosts, activeDvar
end

LUI.createMenu.workbench_menu = function(controller)
    local menu = CoD.Menu.New("workbench_menu")
    if not menu then return nil end

    menu.isPopup = true
    if CoD.Menu.MakePopup then
        CoD.Menu.MakePopup(menu)
    end

    menu:setOwner(controller)
    menu:setHandleMouse(true)
    menu:registerEventHandler("mousemove", CoD.Menu.MouseMove)
    menu:registerEventHandler("mousedown", CoD.Menu.MouseDown)

    local function closeMenu(ctrl)
        Engine.SendMenuResponse(ctrl, "workbench_menu", "close")
        CoD.Menu.goBack(menu, ctrl)
        CoD.WorkBenchMenu.ActiveMenu = nil
    end

    menu:registerEventHandler("key_down", function(element, event)
        if event.key == 27 then
            closeMenu(event.controller)
            return true
        end
    end)

    menu:registerEventHandler("button_prompt_back", function(element, event)
        closeMenu(event.controller)
        return true
    end)

    if menu.addBackButton then
        menu:addBackButton()
    else
        CoD.Menu.AddBackButton(menu)
    end


    local frame = LUI.UIElement.new()
    frame:setLeftRight(false, false, -200, 200)
    frame:setTopBottom(false, false, -135, 135)
    menu:addElement(frame)


    local bg = LUI.UIImage.new()
    bg:setLeftRight(true, true, 0, 0)
    bg:setTopBottom(true, true, 0, 0)
    pcall(function()
        bg:setImage(RegisterMaterial("ui_menu_wonderfizz"))
    end)
    bg:setRGB(1, 1, 1)
    bg:setAlpha(1.0)
    frame:addElement(bg)


    local title = LUI.UIText.new()
    title:setLeftRight(true, true, 12, -12)
    title:setTopBottom(true, false, 8, 28)
    title:setText("MESA DE CONSTRUÇÃO")
    title:setFont(CoD.fonts.Big)
    title:setAlignment(LUI.Alignment.Center)
    title:setRGB(0.2, 0.2, 0.2)
    frame:addElement(title)


    local itemNameHeader = LUI.UIText.new()
    itemNameHeader:setLeftRight(true, true, 12, -12)
    itemNameHeader:setTopBottom(true, false, 30, 48)
    itemNameHeader:setText("SELECIONE UM ITEM")
    itemNameHeader:setFont(CoD.fonts.Condensed)
    itemNameHeader:setAlignment(LUI.Alignment.Center)
    itemNameHeader:setRGB(0.85, 0.65, 0.12)
    frame:addElement(itemNameHeader)

    local itemCostHeader = LUI.UIText.new()
    itemCostHeader:setLeftRight(true, true, 12, -12)
    itemCostHeader:setTopBottom(true, false, 54, 70)
    itemCostHeader:setText("")
    itemCostHeader:setFont(CoD.fonts.Condensed)
    itemCostHeader:setAlignment(LUI.Alignment.Center)
    itemCostHeader:setRGB(0.85, 0.70, 0.15)
    frame:addElement(itemCostHeader)


    local scoreText = LUI.UIText.new()
    scoreText:setLeftRight(true, true, 0, 0)
    scoreText:setTopBottom(false, true, -26, -6)
    scoreText:setFont(CoD.fonts.Condensed)
    scoreText:setAlignment(LUI.Alignment.Center)
    scoreText:setRGB(0.85, 0.70, 0.15)
    frame:addElement(scoreText)


    local itemMasterList = {
        { code = "cymbal_monkey_zm",   name = "MONKEY BOMB",     material = "ui_icon_zombie_purchasemenu_monkeybomb" },
        { code = "emp_grenade_zm",      name = "EMP GRENADE",    material = "ui_icon_zombie_purchasemenu_stungrenade" },
        { code = "sticky_grenade_zm",   name = "SEMTEX GRENADE", material = "ui_icon_zombie_purchasemenu_semtex" },
        { code = "molotov_zm",          name = "MOLOTOV",        material = "ui_icon_zombie_purchasemenu_molotov" },
        { code = "claymore_zm",         name = "CLAYMORE",       material = "ui_icon_zombie_purchasemenu_claymore" },
        { code = "self_revive",         name = "SELF REVIVE",    material = "ui_icon_zombie_purchasemenu_selfrevive" },
        { code = "minigun_zm", name = "DEATH MACHINE",  material = "ui_icon_zombie_purchasemenu_deathmachine" },
        { code = "mgl_zm",              name = "WAR MACHINE",    material = "ui_icon_zombie_purchasemenu_grenadelauncher" },
        { code = "flamethrower_zm",     name = "FLAMETHROWER",   material = "ui_icon_zombie_purchasemenu_flamethrower" },
        { code = "equip_turret_zm",     name = "SENTRY GUN",     material = "ui_icon_zombie_purchasemenu_sentryturret" },
        { code = "remote_mortar_mp",    name = "MORTAR STRIKE",  material = "ui_icon_zombie_purchasemenu_artillerystrike" }
    }

    local activeMap, activeCosts, activeDvar = parseWorkbenchItems()

    local itemOptions = {}
    for _, item in ipairs(itemMasterList) do
        if activeMap[item.code] or activeDvar == "" then
            table.insert(itemOptions, item)
        end
    end
    
    table.insert(itemOptions, { code = "close", name = "FECHAR", label = "X" })

    local cols = 6
    local cardW, cardH = 52, 52
    local gapX, gapY = 8, 10
    local startX = 24
    local startY = 75

    local cards = {}
    local focusedIndex = 0

    for i, item in ipairs(itemOptions) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)

        local xL = startX + col * (cardW + gapX)
        local yT = startY + row * (cardH + gapY)

        local card = LUI.UIButton.new()
        card:setLeftRight(true, false, xL, xL + cardW)
        card:setTopBottom(true, false, yT, yT + cardH)
        card:setHandleMouse(true)

        card:clearGainFocusSFX()

        card.item = item
        card.canAfford = true


        local cardBG = LUI.UIImage.new()
        cardBG:setLeftRight(true, true, 0, 0)
        cardBG:setTopBottom(true, true, 0, 0)
        cardBG:setImage(RegisterMaterial("white"))
        cardBG:setRGB(0.50, 0.50, 0.50)
        cardBG:setAlpha(0.95)
        cardBG:setHandleMouse(false)
        card:addElement(cardBG)
        card.cardBG = cardBG

        if item.material then
            local icon = LUI.UIImage.new()
            icon:setLeftRight(true, true, 4, -4)
            icon:setTopBottom(true, true, 4, -4)
            pcall(function()
                icon:setImage(RegisterMaterial(item.material))
            end)
            icon:setHandleMouse(false)
            card:addElement(icon)
            card.icon = icon
        else
            local labelTxt = LUI.UIText.new()
            labelTxt:setLeftRight(true, true, 2, -2)
            labelTxt:setTopBottom(false, false, -12, 12)
            labelTxt:setText(item.label or "X")
            labelTxt:setFont(CoD.fonts.Big)
            labelTxt:setAlignment(LUI.Alignment.Center)
            
            if item.code == "close" then
                labelTxt:setRGB(0.8, 0.2, 0.2)
            else
                labelTxt:setRGB(1.0, 1.0, 1.0)
            end
            
            labelTxt:setHandleMouse(false)
            card:addElement(labelTxt)
            card.labelTxt = labelTxt
        end

        card:registerEventHandler("gain_focus", function(element, event)
            if focusedIndex ~= i then
                Engine.PlaySound("cac_grid_nav")
                focusedIndex = i
            end

            local currentScore = UIExpression.DvarInt(nil, "ui_workbench_player_score") or 0
            local _, liveCosts = parseWorkbenchItems()
            local cost = liveCosts[item.code] or 0

            local canAfford = (item.code == "close") or (currentScore >= cost)
            card.canAfford = canAfford

            if canAfford then
                cardBG:setRGB(0.82, 0.62, 0.12)
                cardBG:setAlpha(0.95)
            else
                cardBG:setRGB(0.45, 0.25, 0.15)
                cardBG:setAlpha(0.85)
            end

            itemNameHeader:setText(string.upper(item.name))

            if item.code == "close" then
                itemCostHeader:setText("")
            else
                itemCostHeader:setText("$" .. tostring(cost))
                if canAfford then
                    itemCostHeader:setRGB(0.85, 0.70, 0.15)
                else
                    itemCostHeader:setRGB(0.85, 0.20, 0.20)
                end
            end
            return true
        end)

        card:registerEventHandler("lose_focus", function(element, event)
            if card.canAfford then
                cardBG:setRGB(0.50, 0.50, 0.50)
                cardBG:setAlpha(0.95)
            else
                cardBG:setRGB(0.20, 0.20, 0.20)
                cardBG:setAlpha(0.60)
            end
            return true
        end)


        card:registerEventHandler("button_action", function(element, event)
            if item.code == "close" then
                closeMenu(event.controller)
            else
                Engine.SendMenuResponse(event.controller, "workbench_menu", item.code)
            end
            return true
        end)

        frame:addElement(card)
        table.insert(cards, card)
    end

    menu.updateState = function()
        local currentScore = UIExpression.DvarInt(nil, "ui_workbench_player_score") or 0
        scoreText:setText("$" .. tostring(currentScore))

        local _, liveCosts = parseWorkbenchItems()

        for idx, card in ipairs(cards) do
            local item = card.item
            if item and item.code ~= "close" then
                local cost = liveCosts[item.code] or 0

                local canAfford = currentScore >= cost
                card.canAfford = canAfford

                if card.icon then
                    if canAfford then
                        card.icon:setRGB(1.0, 1.0, 1.0)
                        card.icon:setAlpha(1.0)
                    else
                        card.icon:setRGB(0.30, 0.30, 0.30)
                        card.icon:setAlpha(0.40)           
                    end
                end

                if idx ~= focusedIndex and card.cardBG then
                    if canAfford then
                        card.cardBG:setRGB(0.50, 0.50, 0.50)
                        card.cardBG:setAlpha(0.95)
                    else
                        card.cardBG:setRGB(0.20, 0.20, 0.20)
                        card.cardBG:setAlpha(0.60)
                    end
                end
            end
        end

        if focusedIndex > 0 and cards[focusedIndex] then
            cards[focusedIndex]:processEvent({ name = "gain_focus" })
        end
    end


    menu:updateState()

    menu:registerEventHandler("workbench_update", function(element, event)
        menu:updateState()
        return true
    end)


    menu:registerEventHandler("gain_focus", function(element, event)
        if focusedIndex == 0 then
            return true
        end
    end)


    local function changeFocus(newIndex, ctrl)
        if newIndex < 1 or newIndex > #cards or newIndex == focusedIndex then return end
        if focusedIndex > 0 and cards[focusedIndex] then
            cards[focusedIndex]:processEvent({ name = "lose_focus", controller = ctrl })
        end
        if cards[newIndex] then
            cards[newIndex]:processEvent({ name = "gain_focus", controller = ctrl })
        end
    end

    local function moveLeft(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if (focusedIndex - 1) % cols ~= 0 then
            changeFocus(focusedIndex - 1, ctrl)
        end
    end

    local function moveRight(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if focusedIndex % cols ~= 0 and (focusedIndex + 1) <= #cards then
            changeFocus(focusedIndex + 1, ctrl)
        end
    end

    local function moveUp(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        if (focusedIndex - cols) >= 1 then
            changeFocus(focusedIndex - cols, ctrl)
        end
    end

    local function moveDown(ctrl)
        if focusedIndex == 0 then changeFocus(1, ctrl) return end
        local total = #cards
        local target = focusedIndex + cols
        if target <= total then
            changeFocus(target, ctrl)
        else
            local lastRowStart = math.floor((total - 1) / cols) * cols + 1
            if focusedIndex < lastRowStart then
                changeFocus(total, ctrl)
            end
        end
    end


    menu:registerEventHandler("left", function(element, event) moveLeft(event.controller) return true end)
    menu:registerEventHandler("right", function(element, event) moveRight(event.controller) return true end)
    menu:registerEventHandler("up", function(element, event) moveUp(event.controller) return true end)
    menu:registerEventHandler("down", function(element, event) moveDown(event.controller) return true end)

    menu:registerEventHandler("gamepad_button", function(element, event)
        if not event.down then return end

        local btn = event.button
        if btn == "left" then moveLeft(event.controller) return true
        elseif btn == "right" then moveRight(event.controller) return true
        elseif btn == "up" then moveUp(event.controller) return true
        elseif btn == "down" then moveDown(event.controller) return true
        elseif btn == "primary" then
            if focusedIndex > 0 and cards[focusedIndex] then
                cards[focusedIndex]:processEvent({ name = "button_action", controller = event.controller })
                return true
            end
        elseif btn == "secondary" or btn == "back" then
            closeMenu(event.controller)
            return true
        end
    end)

    return menu
end

CoD.WorkBenchMenu.Register = function(hudWidget, controller)
    hudWidget:registerEventHandler("workbench_toggle", function(widget, event)
        local currentController = event.controller or controller or 0
        local popup = CoD.Menu.openPopup(widget, "workbench_menu", currentController)
        if popup then
            CoD.WorkBenchMenu.ActiveMenu = popup
        end
    end)

    hudWidget:registerEventHandler("workbench_update", function(widget, event)
        if CoD.WorkBenchMenu.ActiveMenu and CoD.WorkBenchMenu.ActiveMenu.updateState then
            CoD.WorkBenchMenu.ActiveMenu:updateState()
        end
    end)

    hudWidget:registerEventHandler("workbench_close", function(widget, event)
        if CoD.WorkBenchMenu.ActiveMenu then
            local currentController = event.controller or controller or 0
            CoD.Menu.goBack(CoD.WorkBenchMenu.ActiveMenu, currentController)
            CoD.WorkBenchMenu.ActiveMenu = nil
        end
    end)
end
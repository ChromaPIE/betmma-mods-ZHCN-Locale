--- STEAMODDED HEADER
--- MOD_NAME: Betmma Vouchers
--- MOD_ID: BetmmaVouchers
--- MOD_AUTHOR: [Betmma]
--- MOD_DESCRIPTION: 34 More Vouchers and 9 Fusion Vouchers!
--- BADGE_COLOUR: ED40BF

----------------------------------------------
------------MOD CODE -------------------------
-- thanks to Denverplays2, RenSixx, KEKC and other discord users for their ideas
-- ideas:
-- peek the first card in packs (impractical?) / skipped packs get 50% refund
-- Global Interpreter Lock: set all jokers to eternal / not eternal, once per round (more like an ability that is used manually)
-- sold jokers become a tag that replaces the next joker appearing in shop (also an ability)
-- stone cards don't take up hand space (so you can play 5 cards + any stones)
-- complete a quest to get a soul
-- fusion vouchers:
-- Magic Trick + Reroll Surplus: return all cards to deck if deck has no cards
-- Overstock + Reroll Surplus could make it so that whenever you buy something, it's automatically replaced with a card of the same type
-- Oversupply Plus and 4D Boosters: Rerolls in the shop also reroll the voucher (if it wasn't purchased).
-- Epilogue and Engulfer: When blind ends, create a negative Black Hole.
-- Epilogue and Scribble: Spectral cards received from Epilogue are negative.
-- Oversupply Plus and Overstock Plus: +1 voucher slot available at shop.
-- Glow Up and Illusion: Playing cards in the shop always have an edition and may have an enhancement and/or a seal.          Or: Playing cards in the shop always have an enhancement, edition and a seal.
-- Darkness and Double Planet: the planet card generated is negative

-- Config: DISABLE UNWANTED MODS HERE
local config = {
    -- normal vouchers
    v_oversupply=true,
    v_oversupply_plus=true,
    v_gold_coin=true,
    v_gold_bar=true,
    v_abstract_art=true,
    v_mondrian=true,
    v_round_up=true,
    v_round_up_plus=true,
    v_event_horizon=true,
    v_engulfer=true,
    v_target=true,
    v_bulls_eye=true,
    v_voucher_bundle=true,
    v_voucher_bulk=true,
    v_skip=true,
    v_skipper=true,
    v_scrawl=true,
    v_scribble=true,
    v_reserve_area=true,
    v_reserve_area_plus=true,
    v_overkill=true,
    v_big_blast=true,
    v_3d_boosters=true,
    v_4d_boosters=true,
    v_b1g50=true,
    v_b1g1=true,
    v_collector=true,
    v_connoisseur=true,
    v_flipped_card=true,
    v_double_flipped_card=true,
    v_prologue=true,
    v_epilogue=true,
    v_bonus_plus=true,
    v_mult_plus=true,
    -- fusion vouchers
    v_gold_round_up=true,
    v_overshopping=true,
    v_reroll_cut=true,
    v_vanish_magic=true,
    v_darkness=true,
    v_double_planet=true,
    v_trash_picker=true,
    v_money_target=true,
    v_art_gallery=true
}


local function randomly_redeem_voucher(no_random_please) -- xD
    -- local voucher_key = time==0 and "v_voucher_bulk" or get_next_voucher_key(true)
    -- time=1
    local voucher_key = no_random_please or get_next_voucher_key(true)
    local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
    card:start_materialize()
    G.play:emplace(card)
    card.cost=0
    card.shop_voucher=false
    local current_round_voucher=G.GAME.current_round.voucher
    card:redeem()
    G.GAME.current_round.voucher=current_round_voucher -- keep the shop voucher unchanged since the voucher bulk may be from voucher pack or other non-shop source
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        --blockable = false,
        --blocking = false,
        delay =  0,
        func = function() 
            card:start_dissolve()
            return true
        end}))   
end

local function randomly_create_joker(jokers_to_create,tag,message,extra)
    extra=extra or {}
    G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
    G.E_MANAGER:add_event(Event({
        func = function() 
            for i = 1, jokers_to_create do
                local card = create_card('Joker', G.jokers, nil, 0, nil, nil, nil, tag)
                card:add_to_deck()
                if extra.edition~=nil then
                    card:set_edition(extra.edition,true,false)
                end
                G.jokers:emplace(card)
                card:start_materialize()
                G.GAME.joker_buffer = 0
            
                if message~=nil then
                    card_eval_status_text(card,'jokers',nil,nil,nil,{message=message})
                end
            end
            return true
        end}))   
end
local function randomly_create_consumable(card_type,tag,message,extra)
    extra=extra or {}
    
    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit or extra and extra.edition and extra.edition.negative then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.0,
            func = (function()
                    local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, nil, tag)
                    card:add_to_deck()
                    if extra.edition~=nil then
                        card:set_edition(extra.edition,true,false)
                    end
                    if extra.eternal~=nil then
                        card.ability.eternal=extra.eternal
                    end
                    if extra.perishable~=nil then
                        card.ability.perishable = extra.perishable
                        if tag=='v_epilogue' then
                            card.ability.perish_tally=G.P_CENTERS.v_epilogue.config.extra
                        else card.ability.perish_tally = G.GAME.perishable_rounds
                        end
                    end
                    if extra.extra_ability~=nil then
                        card.ability[extra.extra_ability]=true
                    end
                    card.ability.BetmmaVouchers=true
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    if message~=nil then
                        card_eval_status_text(card,'extra',nil,nil,nil,{message=message})
                    end
                return true
            end)}))
    end
end
local function randomly_create_spectral(tag,message,extra)
    return randomly_create_consumable('Spectral',tag,message,extra)
end
local function randomly_create_tarot(tag,message,extra)
    return randomly_create_consumable('Tarot',tag,message,extra)
end
local function randomly_create_planet(tag,message,extra)
    return randomly_create_consumable('Planet',tag,message,extra)
end

local function get_weight(v)
    local _type=type(v)

    if _type~='table' and _type~='string' then return 1 end
    -- if _type=='table' and v.name == "Ace of Spades"then return 9999 end
    if _type=='string' then
        if G.P_CENTERS[v] then
            v=G.P_CENTERS[v]
        end
    end
    if v.weight then return v.weight end
    if v.config and v.config.weight then return v.config.weight end
    return 1
end

local function pseudorandom_element_weighted(_t, seed)
    if seed then math.randomseed(seed) end
    -- local keys = {}
    -- for k, v in pairs(_t) do
    --     keys[#keys+1] = {k = k,v = v}
    -- end
  
    -- if keys[1] and keys[1].v and type(keys[1].v) == 'table' and keys[1].v.sort_id then
    --   table.sort(keys, function (a, b) return a.v.sort_id < b.v.sort_id end)
    -- else
    --   table.sort(keys, function (a, b) return a.k < b.k end)
    -- end
    local _type
    local cume, it, center, center_key = 0, 0, nil, nil
    for k, v in pairs(_t) do
        _type=type(v)
        if (_type~='table') or (not G.GAME.banned_keys[v.key]) then cume = cume + get_weight(v) end
    end
    local poll = pseudorandom(pseudoseed((seed or 'weighted_random')..G.GAME.round_resets.ante))*cume
    
    for k, v in pairs(_t) do
        if (_type~='table') or (not G.GAME.banned_keys[v.key]) then 
            it = it + get_weight(v) 
            if it >= poll and it - get_weight(v) <= poll then center = v; center_key=k; break end
        end
    end
    if center == nil then center.a() end
    return center,center_key
end

function SMODS.INIT.BetmmaVouchers()
    local get_next_voucher_key_ref=get_next_voucher_key
    function get_next_voucher_key(_from_tag)
        -- local _pool, _pool_key = get_current_pool('Voucher')
        -- this pool contains strings
        local pseudorandom_element_ref=pseudorandom_element
        pseudorandom_element=pseudorandom_element_weighted
        local ret= get_next_voucher_key_ref(_from_tag)
        pseudorandom_element=pseudorandom_element_ref
        return ret
    end

    local fusion_voucher_weight=4
    local SMODS_Voucher_register=SMODS.Voucher.register
    function SMODS.Voucher:register()
        if SMODS._MOD_NAME=='Betmma Vouchers' then
            if not config[self.slug] then return false end
            if self.requires and #self.requires>1 then 
                self.config.weight=fusion_voucher_weight
            end
        end
        SMODS_Voucher_register(self)
    end

do
    local oversupply_loc_txt = {
        name = "供应过量",
        text = {
            "击败Boss盲注后",
            "获得{C:attention}1{}个{C:attention}奖券标签"
        }
    }
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_oversupply = SMODS.Voucher:new(
        "Oversupply", "oversupply",
        {},
        {x=0,y=0}, oversupply_loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_oversupply", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply.png", 71, 95, "asset_atli"):register();
    v_oversupply:register()
    
    local oversupply_plus_loc_txt = {
        name = "Oversupply Plus",
        text = {
            "Gain {C:attention}1{} {C:attention}Voucher Tag{}",
            "after beating every blind"
            -- if you have both, after beating boss blind you gain only 1 voucher tag
        }
    }
    local v_oversupply_plus = SMODS.Voucher:new(
            "Oversupply Plus", "oversupply_plus",
            {},
            {x=0,y=0}, oversupply_plus_loc_txt,
            10, true, true, true, {'v_oversupply'}
        )
    SMODS.Sprite:new("v_oversupply_plus", SMODS.findModByID("BetmmaVouchers").path, "v_oversupply_plus.png", 71, 95, "asset_atli"):register();
    v_oversupply_plus:register()
    -- The v.redeem function mentioned in voucher.lua of steamodded 0.9.5 is bugged when the voucher is given at the beginning of the game (such as challenge or some decks), and also it's not capable of making not one-time effects.
    local end_round_ref = end_round
    function end_round()
        if G.GAME.used_vouchers.v_oversupply and G.GAME.blind:get_type() == 'Boss' or G.GAME.used_vouchers.v_oversupply_plus then
            add_tag(Tag('tag_voucher'))
        end
        end_round_ref()
    end


end --
do 
    local name="Gold Coin"
    local id="gold_coin"
    local gold_coin_loc_txt = {
        name = "金币",
        text = {
            "立即获得{C:money}$#1#",
            "{C:attention}小盲注{}将失去奖励金"
            -- yes it literally does nothing bad after white stake
        }
    }
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_coin = SMODS.Voucher:new(
        name, id,
        {extra=20},
        {x=0,y=0}, gold_coin_loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_coin.png", 71, 95, "asset_atli"):register();
    v_gold_coin:register()
    v_gold_coin.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Gold Bar"
    local id="gold_bar"
    local gold_bar_loc_txt = {
        name = name,
        text = {
            "Gain {C:money}$#1#{} immediately.",
            "{C:attention}Big Blind{} gives",
            "no reward money",
        }
    }
    --function SMODS.Voucher:new(name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas)
    local v_gold_bar = SMODS.Voucher:new(
        name, id,
        {extra=25},
        {x=0,y=0}, gold_bar_loc_txt,
        10, true, true, true, {'v_gold_coin'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_gold_bar.png", 71, 95, "asset_atli"):register();
    v_gold_bar:register()
    v_gold_bar.loc_def = function(self)
        return {self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Gold Coin' or center_table.name == 'Gold Bar' then
            ease_dollars(center_table.extra)
        end
        if center_table.name == 'Gold Coin' then
            G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
            G.GAME.modifiers.no_blind_reward.Small = true
        end
        if center_table.name == 'Gold Bar' then
            G.GAME.modifiers.no_blind_reward = G.GAME.modifiers.no_blind_reward or {}
            G.GAME.modifiers.no_blind_reward.Big = true
        end
        Card_apply_to_run_ref(self, center)
    end



end --
do 
    
    local name="Abstract Art"
    local id="abstract_art"
    local loc_txt = {
        name = "抽象艺术",
        text = {
            "每回合出牌和弃牌次数各{C:blue}+#1#",
            "赢下游戏需通关底注数{C:attention}+#1#"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Mondrian"
    local id="mondrian"
    local loc_txt = {
        name = "蒙德里安",
        text = {
            "{C:attention}+#1#{}小丑牌槽位",
            "赢下游戏需通关底注数{C:attention}+#1#"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_abstract_art'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Abstract Art' then
            ease_ante_to_win(center_table.extra)
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + center_table.extra
            ease_hands_played(center_table.extra)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + center_table.extra
            ease_discard(center_table.extra)
        end
        if center_table.name == 'Mondrian' then
            ease_ante_to_win(center_table.extra)
            G.E_MANAGER:add_event(Event({func = function()
                if G.jokers then 
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                end
                return true end }))
        end
        Card_apply_to_run_ref(self, center)
    end


    function ease_ante_to_win(mod)
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
              local ante_UI = G.hand_text_area.ante
              mod = mod or 0
              local text = '+'
              local col = G.C.IMPORTANT
              if mod < 0 then
                  text = '-'
                  col = G.C.RED
              end
              ante_UI.config.object:update()
              --If this line is written in the apply_to_run function above, the ante to win number will increase before the animation begins
              G.GAME.win_ante=G.GAME.win_ante+mod
              G.HUD:recalculate()
              --Popup text next to the chips in UI showing number of chips gained/lost
              attention_text({
                text = text..tostring(math.abs(mod)),
                scale = 1, 
                hold = 0.7,
                cover = ante_UI.parent,
                cover_colour = col,
                align = 'cm',
                })
              --Play a chip sound
              play_sound('highlight2', 0.685, 0.2)
              play_sound('generic1')
              return true
          end
        }))
    end

    
end --
do 

    local name="Round Up"
    local id="round_up"
    local loc_txt = {
        name = "凑个整儿",
        text = {
            "出牌计分时",
            "每次计入的{C:blue}筹码",
            "均向上取整至十位数"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return nil
    end

    
    local name="Round Up Plus"
    local id="round_up_plus"
    local loc_txt = {
        name = "凑个整儿 Plus版",
        text = {
            "出牌计分时",
            "每次计入的{C:red}倍率",
            "均向上取整至十位数"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=5},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_round_up'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local mod_chips_ref=mod_chips
    function mod_chips(_chips)
        if G.GAME.used_vouchers.v_round_up then
          _chips = math.ceil(_chips/10)*10
        end
        return mod_chips_ref(_chips)
    end
    local mod_mult_ref=mod_mult
    function mod_mult(_mult)
        if G.GAME.used_vouchers.v_round_up_plus then
            _mult=math.ceil(_mult/10)*10
        end
        return mod_mult_ref(_mult)
    end


end --
do 
    
    local name="Event Horizon"
    local id="event_horizon"
    local loc_txt = {
        name = "事件视界",
        text = {
            "购买本奖券后即刻生成",
            "{C:attention}2{}张随机的{C:dark_edition}负片{C:planet}星球牌",
            "开启天体包时有{C:green}#1#/#2#{}的几率",
            "生成一张{C:spectral}黑洞"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {""..(G.GAME and G.GAME.probabilities.normal or 1),self.config.extra}
    end

    
    local name="Engulfer"
    local id="engulfer"
    local loc_txt = {
        name = "万物终焉",
        text = {
            "购买本奖券后",
            "即刻生成一张{C:spectral}黑洞",
            "使用星球牌时有{C:green}#1#/#2#{}的几率",
            "生成一张{C:spectral}黑洞",
            "{C:inactive}（必须有空间）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=5},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_event_horizon'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {""..(G.GAME and G.GAME.probabilities.normal or 1),self.config.extra}
    end

    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Event Horizon' then
            
            for i = 1, 2 do
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    if 1 then
                        play_sound('timpani')
                        local card = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'Event Horizon')
                        card:set_edition({negative=true},true,false)
                        card:add_to_deck()
                        G.consumeables:emplace(card)
                    end
                    return true end }))
            end
        end
        if center_table.name == 'Engulfer' then
            create_black_hole()
        end
        Card_apply_to_run_ref(self, center)
    end

    local Card_open_ref=Card.open
    function Card:open()
        if self.ability.set == "Booster" and self.ability.name:find('Celestial') and G.GAME.used_vouchers.v_event_horizon and
        pseudorandom('event_horizon') < G.GAME.probabilities.normal/G.P_CENTERS.v_event_horizon.config.extra then
            create_black_hole()
        end
        return Card_open_ref(self)
    end

    local G_FUNCS_use_card_ref = G.FUNCS.use_card
    G.FUNCS.use_card =function(e, mute, nosave)
        local card = e.config.ref_table
        if card.ability.consumeable then
            if card.ability.set == 'Planet' and G.GAME.used_vouchers.v_engulfer and pseudorandom('engulfer') < G.GAME.probabilities.normal/G.P_CENTERS.v_engulfer.config.extra then
                create_black_hole()
            end
        end
        G_FUNCS_use_card_ref(e, mute, nosave)
    end

    function create_black_hole()
        if #G.consumeables.cards + G.GAME.consumeable_buffer >= G.consumeables.config.card_limit then return end
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'before',
            delay = 0.0,
            func = (function()
                    local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, 'c_black_hole', 'v_event_horizon_or_v_engulfer')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    return true
                    end)}))
    end


end --
do 

    
    local name="Target"
    local id="target"
    local loc_txt = {
        name = "射箭标靶",
        text = {
            "若回合结束时的得分",
            "为最低要求的{C:attention}#1#%{}或更低",
            "随机生成一张{C:attention}小丑牌",
            "{C:inactive}（必须有空间）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=120},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Bull's Eye"
    local id="bulls_eye"
    local loc_txt = {
        name = "正中十环",
        text = {
            "若回合结束时的得分",
            "为最低要求的{C:attention}#1#%{}或更低",
            "随机生成一张{C:dark_edition}负片{C:attention}小丑牌",
            "{C:inactive}（必须有空间）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=105},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_target'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local end_round_ref=end_round
    function end_round()

        if G.GAME.used_vouchers.v_target and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips*100 - G.GAME.blind.chips*G.P_CENTERS.v_target.config.extra <= 0 then
            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                local jokers_to_create = math.min(1, G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
                randomly_create_joker(jokers_to_create,'target',localize("k_target_generate"))
            end
        end
        if G.GAME.used_vouchers.v_bulls_eye and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips*100 - G.GAME.blind.chips*G.P_CENTERS.v_bulls_eye.config.extra <= 0 then
            randomly_create_joker(1,'target',localize("k_bulls_eye_generate"),{edition={negative=true}})
        end

        end_round_ref()
    end

    G.localization.misc.dictionary.k_target_generate = "标靶！"
    G.localization.misc.dictionary.k_bulls_eye_generate = "正中十环！"


end --
do 

    local name="Voucher Bundle"
    local id="voucher_bundle"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:Attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=2},
        {x=0,y=0}, loc_txt,
        15, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Voucher Bulk"
    local id="voucher_bulk"
    local loc_txt = {
        name = name,
        text = {
            "Gives {C:Attention}#1#{} random vouchers"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        25, true, true, true, {'v_voucher_bundle'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
        
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Voucher Bundle' then
            for i=1, G.P_CENTERS.v_voucher_bundle.config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        if center_table.name == 'Voucher Bulk' then
            for i=1, G.P_CENTERS.v_voucher_bulk.config.extra do
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    delay =  0,
                    func = function() 
                        randomly_redeem_voucher()
                        return true
                    end}))   
            end
        end
        Card_apply_to_run_ref(self, center)
    end
    -- local Card_redeem_ref = Card.redeem
    -- function Card:redeem() -- use redeem instead of apply to run because redeem happens before modification of used_vouchers
        
    --     local center_table = {
    --         name = self.ability.name,
    --         extra = self.ability.extra
    --     }
    --     if center_table.name == 'Voucher Bundle' then
    --         for i=1, G.P_CENTERS.v_voucher_bundle.config.extra do
    --             G.E_MANAGER:add_event(Event({
    --                 trigger = 'before',
    --                 delay =  0,
    --                 func = function() 
    --                     randomly_redeem_voucher()
    --                     return true
    --                 end}))   
    --         end
    --     end
    --     if center_table.name == 'Voucher Bulk' then
    --         for i=1, G.P_CENTERS.v_voucher_bulk.config.extra do
    --             G.E_MANAGER:add_event(Event({
    --                 trigger = 'before',
    --                 delay =  0,
    --                 func = function() 
    --                     randomly_redeem_voucher()
    --                     return true
    --                 end}))   
    --         end
    --     end

    
    --     Card_redeem_ref(self)
    -- end
    -- local time=0

end --
do 

    local name="Skip"
    local id="skip"
    local loc_txt = {
        name = "大步流星",
        text = {
            "跳过盲注时获得{C:money}$#1#"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Skipper"
    local id="skipper"
    local loc_txt = {
        name = "乘风破浪",
        text = {
            "跳过盲注时获得一个{C:attention}双倍标签"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_skip'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}--{self.config.extra}
    end

    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    G.FUNCS.skip_blind=function(e)
        if G.GAME.used_vouchers.v_skip then
            ease_dollars(G.P_CENTERS.v_skip.config.extra)
        end
        if G.GAME.used_vouchers.v_skipper then
            add_tag(Tag('tag_double'))
        end
        return G_FUNCS_skip_blind_ref(e)
    end

    
end --
do 
        
    local name="Scrawl"
    local id="scrawl"
    local loc_txt = {
        name = "狗爬字",
        text = {
            "每有一张小丑牌给予{C:money}$#1#",
            "并随机生成{C:attention}小丑牌",
            "直至填满槽位"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=2},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Scribble"
    local id="scribble"
    local loc_txt = {
        name = "胡写乱画",
        text = {
            "随机生成{C:attention}#1#{}张",
            "{C:dark_edition}负片{C:spectral}幻灵牌"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=3},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_scrawl'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Scrawl' then
            ease_dollars(G.P_CENTERS.v_scrawl.config.extra*#G.jokers.cards)
            randomly_create_joker(G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer),nil,nil)
        end
        if center_table.name == 'Scribble' then
            for i=1, G.P_CENTERS.v_scribble.config.extra do
                randomly_create_spectral(nil,nil,{edition={negative=true}})
            end
        end
        Card_apply_to_run_ref(self, center)
    end

    
end --
do 

    local name="Reserve Area"
    local id="reserve_area"
    local loc_txt = {
        name = "打包带走",
        text = {
            "在{C:tarot}秘术包{}中选取的{C:tarot}塔罗牌",
            "可存入消耗牌槽位"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}--{self.config.extra}
    end

    
    local name="Reserve Area Plus"
    local id="reserve_area_plus"
    local loc_txt = {
        name = "连吃带拿",
        text = {
            "在{C:spectral}幻灵包{}中选取的{C:spectral}幻灵牌",
            "可存入消耗牌槽位",
            "且开启{C:spectral}幻灵包{}时",
            "额外获得一个{C:attention}空灵标签"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_reserve_area'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}--{self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Reserve Area Plus' then
            
            add_tag(Tag('tag_ethereal'))
            -- G.E_MANAGER:add_event(Event({
            --     trigger = 'before',
            --     delay =  0,
            --     func = function() 
                    -- local key = 'p_spectral_mega_1'
                    -- local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                    -- G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    -- card.cost = 0
                    -- G.FUNCS.use_card({config = {ref_table = card}})
                    -- card:start_materialize()
                    -- return true
                -- end}))   
            
            -- Unfortunately I failed to directly open a spectral pack
        end
        Card_apply_to_run_ref(self, center)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        if (card.area == G.pack_cards and G.pack_cards) and card.ability.consumeable then --Add a use button
            if G.STATE == G.STATES.TAROT_PACK and G.GAME.used_vouchers.v_reserve_area or G.STATE == G.STATES.SPECTRAL_PACK and G.GAME.used_vouchers.v_reserve_area_plus then
                return {
                    n=G.UIT.ROOT, config = {padding = -0.1,  colour = G.C.CLEAR}, nodes={
                      {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, minh = 0.7*card.T.h, maxw = 0.7*card.T.w - 0.15, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'use_card', func = 'can_use_consumeable'}, nodes={
                        {n=G.UIT.T, config={text = localize('b_use'),colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true}}
                      }},
                      {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.1*card.T.h, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'Do you know that this parameter does nothing?', func = 'can_reserve_card'}, nodes={
                        {n=G.UIT.T, config={text = localize('b_reserve'),colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
                      }},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}},
                      -- I can't explain it
                  }}
            end
        end
        return G_UIDEF_use_and_sell_buttons_ref(card)
    end
    G.localization.misc.dictionary.b_reserve = "RESERVE"
    G.FUNCS.can_reserve_card = function(e)
        if #G.consumeables.cards < G.consumeables.config.card_limit then 
            e.config.colour = G.C.GREEN
            e.config.button = 'reserve_card' 
        else
          e.config.colour = G.C.UI.BACKGROUND_INACTIVE
          e.config.button = nil
        end
      end
    G.FUNCS.reserve_card = function(e) -- only works for consumeables
        local c1 = e.config.ref_table
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
              c1.area:remove_card(c1)
              c1:add_to_deck()
              if c1.children.price then c1.children.price:remove() end
              c1.children.price = nil
              if c1.children.buy_button then c1.children.buy_button:remove() end
              c1.children.buy_button = nil
              remove_nils(c1.children)
              G.consumeables:emplace(c1)
              G.GAME.pack_choices = G.GAME.pack_choices - 1
              if G.GAME.pack_choices <= 0 then
                G.FUNCS.end_consumeable(nil, delay_fac)
              end
              return true
            end
        }))
    end

    -- local G_UIDEF_card_focus_ui_ref=G.UIDEF.card_focus_ui
    -- function G.UIDEF.card_focus_ui(card)
    -- I suspect that this function does nothing too
    -- because replacing it with empty function seems do no harm

end --
do 

    local name="Overkill"
    local id="overkill"
    local loc_txt = {
        name = "用力过猛",
        text = {
            "若回合结束时的得分",
            "为最低要求的{C:attention}#1#%{}或更高",
            "为随机一张{C:attention}小丑牌添加{C:dark_edition}闪箔{}、",
            "{C:dark_edition}镭射{}或{C:dark_edition}多彩{}的其中一种"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=300},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    
    local name="Big Blast"
    local id="big_blast"
    local loc_txt = {
        name = "瞬间爆炸",
        text = {
            "若回合结束时的得分",
            "为最低要求的{X:mult,C:white}#1#倍{}或更高",
            "为随机一张{C:attention}小丑牌添加{C:dark_edition}负片",
            "并提升上述倍数要求",
            "{C:inactive}（本奖券提供的负片",
            "{C:inactive}可覆盖小丑牌的原有版本）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra={multiplier=5,increase=2}},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_overkill'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        local count=G and G.GAME and G.GAME.v_big_blast_count or 0
        return {self.config.extra.multiplier*self.config.extra.increase^(count*(count+1))}
    end
    local v_big_blast=this_v
    local end_round_ref=end_round
    function end_round()

        if G.GAME.used_vouchers.v_overkill and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips*100 - G.GAME.blind.chips*G.P_CENTERS.v_overkill.config.extra >= 0 then
            local temp_pool={}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.edition) then
                    table.insert(temp_pool, v)
                end
            end
            if #temp_pool>0 then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('v_overkill'))
                    local edition = nil
                    edition = poll_edition('wheel_of_fortune', nil, true, true)
                    -- I think using 'wheel_of_fortune' here is ok
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    
                    card_eval_status_text(eligible_card,'jokers',nil,nil,nil,{message=localize("k_overkill_edition")})
                return true end }))
            end
        end
        if G.GAME.used_vouchers.v_big_blast and G.GAME.chips - G.GAME.blind.chips >= 0 and G.GAME.chips - G.GAME.blind.chips*v_big_blast:loc_def()[1] >= 0 then

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    
                local temp_pool={}
                for k, v in pairs(G.jokers.cards) do
                    if v.ability.set == 'Joker' and not (v.edition and v.edition.negative)then 
                        table.insert(temp_pool, v)
                    end
                end
                -- put calculation of temp_pool inside this event because otherwise if v_overkill set an edition it happens 0.4s later, but this temp_pool is calculated at now, potentially causing selecting the same joker
                if #temp_pool>0 then
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('v_big_blast'))
                    local edition = nil
                    edition = {negative = true}
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    card_eval_status_text(eligible_card,'jokers',nil,nil,nil,{message=localize("k_big_blast_edition")})
                end
            return true end }))
            G.GAME.v_big_blast_count=(G.GAME.v_big_blast_count or 0)+1
            
        end

        end_round_ref()
    end

    G.localization.misc.dictionary.k_overkill_edition = "射穿！"
    G.localization.misc.dictionary.k_big_blast_edition = "炸飞！"


end --
do 

    local name="3D Booster"
    local id="3d_boosters"
    local loc_txt = {
        name = "三维堆叠",
        text = {
            "商店中可供选购的",
            "补充包数量{C:attention}+1"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}--{self.config.extra}
    end
    
    local name="4D Boosters"
    local id="4d_boosters"
    local loc_txt = {
        name = "四维堆叠",
        text = {
            "重掷会对{C:attention}补充包{}生效",
            "但会使新的补充包价格上涨{C:attention}$#1#"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=3},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_3d_boosters'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
    function get_booster_pack_max()
        local value=2
        if G.GAME.used_vouchers.v_3d_boosters then value=value+1 end
        return value
    end
    local Game_update_shop_ref= Game.update_shop
    function Game:update_shop(dt)
        Game_update_shop_ref(self,dt) -- Though the original function is called before, the modification of used_packs happens 0.2s later, so enumerate i from #used_packs+1 to max will add 3 packs
        -- local i=get_booster_pack_max() -- if max number added is 2 or more this may be bugged?
        -- G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
        -- if G.GAME.used_vouchers.v_3d_boosters and not G.GAME.current_round.used_packs[i] then
        --             G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key 
        --             local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
        --             G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
        --             create_shop_card_ui(card, 'Booster', G.shop_booster)
        --             card.ability.booster_pos = i
        --             card:start_materialize()
        --             G.shop_booster:emplace(card)
                
        -- end
    end
    local G_FUNCS_cash_out_ref=G.FUNCS.cash_out
    G.FUNCS.cash_out=function (e)
        G_FUNCS_cash_out_ref(e)
        if G.GAME.used_vouchers.v_3d_boosters then
            my_reroll_shop(get_booster_pack_max()-2,0)
        end
    end
    
    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == '3D Boosters'then
            if G.shop_booster then
                my_reroll_shop(get_booster_pack_max(),0)
            end
        end
        Card_apply_to_run_ref(self, center)
    end
    local G_FUNCS_reroll_shop_ref=G.FUNCS.reroll_shop
    function G.FUNCS.reroll_shop(e)
        G_FUNCS_reroll_shop_ref()
        if G.GAME.used_vouchers.v_4d_boosters then
            my_reroll_shop(get_booster_pack_max(),G.P_CENTERS.v_4d_boosters.config.extra)
        end
    end
    function my_reroll_shop(num,price_mod)
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                for i = #G.shop_booster.cards,1, -1 do
                    local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                    c:remove()
                    c = nil
                end
        
                --save_run()
        
                play_sound('coin2')
                play_sound('other1')
                
                for i = 1, num - #G.shop_booster.cards do
                    G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key 
                    local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                    create_shop_card_ui(card, 'Booster', G.shop_booster)
                    card.cost=card.cost+price_mod
                    card.ability.booster_pos = i
                    card:start_materialize()
                    G.shop_booster:emplace(card)
                end
                return true
                end
            }))
            G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
        
    end


end --
do 


    local name="B1G50%"
    local id="b1g50"
    local loc_txt = {
        name = "第二张半价",
        text = {
            "兑换奖券时有{C:green}#1#%{}的几率",
            "直接获得它的{C:attention}高级变种",
            "并失去{C:money}$#2#",
            "{C:inactive}（上述几率无法倍增）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra={chance=50,lose=5}},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra.chance,self.config.extra.lose}
    end

    
    local name="B1G1"
    local id="b1g1"
    local loc_txt = {
        name = name,
        text = {
            "When you redeem a",
            "{C:attention}tier 1{} Voucher, always",
            "redeem the {C:attention}tier 2{}",
            "one and lose {C:money}$#1#{}"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=10},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_b1g50'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

        
    local Card_redeem_ref = Card.redeem
    function Card:redeem() -- use redeem instead of apply to run because redeem happens before modification of used_vouchers
        if G.GAME.used_vouchers.v_b1g1 or G.GAME.used_vouchers.v_b1g50 and  pseudorandom('b1g1')*100 < G.P_CENTERS.v_b1g50.config.extra.chance then
            local lose=G.P_CENTERS.v_b1g50.config.extra.lose
            if G.GAME.used_vouchers.v_b1g1 then 
                lose=G.P_CENTERS.v_b1g1.config.extra
            end
            lose=math.max(1, math.floor((lose+0.5)*(100-G.GAME.discount_percent)/100)) -- liquidation
            local center_table = {
                name = self.ability.name,
                extra = self.ability.extra
            }
            local vouchers_to_get={}
            for i,v in pairs(G.P_CENTER_POOLS.Voucher) do
                local unredeemed_vouchers={}
                if v.requires and not G.GAME.used_vouchers[v.key]then
                    for i,vv in ipairs(v.requires)do
                        if not G.GAME.used_vouchers[vv] then 
                            table.insert(unredeemed_vouchers,vv)
                        end
                    end
                end
                local only_need=G.P_CENTERS[unredeemed_vouchers[1]]
                if #unredeemed_vouchers==1 and only_need.name==center_table.name then
                    table.insert(vouchers_to_get,v)
                end
            end
            if #vouchers_to_get>0 then
                Card_redeem_ref(self)
                for i,v in pairs(vouchers_to_get) do
                    local card = Card(G.play.T.x + G.play.T.w/2 - G.CARD_W*1.27/2,
                    G.play.T.y + G.play.T.h/2-G.CARD_H*1.27/2, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v,{bypass_discovery_center = true, bypass_discovery_ui = true})
                    --create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
                    card:start_materialize()
                    G.play:emplace(card)
                    card.cost=lose
                    card.shop_voucher=false -- this doesn't help keeping current_round_voucher i guess
                    local current_round_voucher=G.GAME.current_round.voucher
                    card:redeem()
                    G.GAME.current_round.voucher=current_round_voucher -- keep the shop voucher unchanged since the voucher may be from voucher pack or other non-shop source
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        --blockable = false,
                        --blocking = false,
                        delay =  0,
                        func = function() 
                            card:start_dissolve()
                            return true
                        end}))   
                end
                return -- exit the whole function as Card_redeem_ref has been called
            end
        end
        Card_redeem_ref(self)
    end
    
end --
do 

    local name="Collector"
    local id="collector"
    local loc_txt = {
        name = name,
        text = {
            "Each {C:attention}Voucher{} redeemed reduces",
            "Blind requirement by {C:attention}#1#%{}",
            "{C:inactive}(multiplicative){}"
            -- just because modifying get_blind_amount(ante) is easier than
            -- adding mult to score
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
    
    local name="Connoisseur"
    local id="connoisseur"
    local loc_txt = {
        name = name,
        text = {
            "If all {C:attention}Vouchers{} have been redeemed",
            "and you have more than {C:money}$#1#{},",
            "redeeming {C:attention}Blank{} triggers {C:dark_edition}that Voucher{}",
            "and doubles the money requirement"
            
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra={base=20,multiplier=2}},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_collector'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        local count=G and G.GAME and G.GAME.v_blank_count or 0
        return {self.config.extra.base*self.config.extra.multiplier^(count)}
    end
    local v_connoisseur=this_v


    get_blind_amount_ref=get_blind_amount
    function get_blind_amount(ante)
        amount=get_blind_amount_ref(ante)
        if G.GAME.used_vouchers.v_collector then
            amount=amount*(1-G.P_CENTERS.v_collector.config.extra/100)^(G.GAME.vouchers_bought or 0)
        end
        return amount
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        G.GAME.vouchers_bought=(G.GAME.vouchers_bought or 0)+1
        if center_table.name == 'Blank'then
            if G.GAME.used_vouchers.v_connoisseur and G.GAME.vouchers_bought>=#G.P_CENTER_POOLS.Voucher and G.GAME.dollars>=v_connoisseur:loc_def()[1] then
                
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    --blockable = false,
                    --blocking = false,
                    delay =  0,
                    func = function() 
                        --ease_dollars(-v_connoisseur:loc_def()[1])
                        -- the description doesn't say you will pay that amount, so don't ease_dollars feels right lol
                        randomly_redeem_voucher("v_antimatter")
                        G.GAME.v_blank_count= (G.GAME.v_blank_count or 0)+1
                        return true
                    end}))   
            end
        end
        Card_apply_to_run_ref(self, center)
    end

end --
do 

    local name="Flipped Card"
    local id="flipped_card"
    local loc_txt = {
        name = "暗斗明争",
        text = {
            "每次出牌前有一次机会",
            "将至多#1#张牌{C:attention}翻面",
            "{C:attention}背面朝上{}的卡牌",
            "会在计分完毕后回到手中"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=3},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end
    
    local name="Double Flipped Card"
    local id="double_flipped_card"
    local loc_txt = {
        name = "潜行伏击",
        text = {
            "{C:attention}背面朝上{}的卡牌",
            "将在手牌中参与计分",
            "且可触发手牌中效果",
            "{C:inactive}（如钢铁牌）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_flipped_card'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end
    
    local create_UIBox_buttons_ref=create_UIBox_buttons
    function create_UIBox_buttons()
        local ret=create_UIBox_buttons_ref()
        local text_scale=0.45
        local button_height=1.3
        if (G.GAME.used_vouchers.v_flipped_card or G.GAME.used_vouchers.v_double_flipped_card) then
            local flip_button={n=G.UIT.C, config={id = 'flip_button', align = "tm", minw = 2.5, padding = 0.3, r = 0.1, hover = true, colour = G.C.PURPLE, button = "this is another useless parameter", one_press = true, shadow = true, func = 'can_flip'}, nodes={
                {n=G.UIT.R, config={align = "bcm", padding = 0}, nodes={
                {n=G.UIT.T, config={text = localize('b_flip_hand'), scale = text_scale, colour = G.C.UI.TEXT_LIGHT, focus_args = {button = 'x', orientation = 'bm'}, func = 'set_button_pip'}}
                }},
            }}
            table.insert(ret.nodes,flip_button)
        end
        return ret
    end

    local G_FUNCS_play_cards_from_highlighted_ref=G.FUNCS.play_cards_from_highlighted
    G.FUNCS.play_cards_from_highlighted=function(e)
        for i=1, #G.hand.highlighted do
            G.hand.highlighted[i].facing_ref=G.hand.highlighted[i].facing
        end
        -- when played all cards will be face up so its facing status before playing should be saved elsewhere
        G.GAME.current_round.flips_left=1
        local ret= G_FUNCS_play_cards_from_highlighted_ref(e)
        return ret
    end

    local new_round_ref=new_round
    function new_round()
        G.GAME.current_round.flips_left=1
        new_round_ref()
    end

    G.FUNCS.can_flip=function(e)
        if #G.hand.highlighted <= 0 or #G.hand.highlighted > G.P_CENTERS.v_flipped_card.config.extra or G.GAME.current_round.flips_left <= 0 then 
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        else
            e.config.colour = G.C.PURPLE
            e.config.button = 'flip_cards_from_highlighted'
        end
    end
    
    G.FUNCS.flip_cards_from_highlighted=function(e)
        stop_use()
        G.CONTROLLER.interrupt.focus = true
        G.CONTROLLER:save_cardarea_focus('hand')
        for i=1, #G.hand.highlighted do
            G.hand.highlighted[i]:flip()
        end
        G.GAME.current_round.flips_left=(G.GAME.current_round.flips_left or 1)-1
    end

    G.localization.misc.dictionary.b_flip_hand = "翻面"

    local G_FUNCS_draw_from_play_to_discard_ref=G.FUNCS.draw_from_play_to_discard
    G.FUNCS.draw_from_play_to_discard = function(e)
        if (G.GAME.used_vouchers.v_flipped_card and not G.GAME.used_vouchers.v_double_flipped_card) then
            local play_count = #G.play.cards --G.GAME.scoring_hand --G.GAME.scoring_hand is stored in eval_hand by me
            local it = 1
            local flag=false
            for k, v in ipairs(G.play.cards) do
                if v.facing_ref=='back' and (not v.shattered) and (not v.destroyed) and (not v.debuff)then
                    draw_card(G.play,G.hand, it*100/play_count,'down', false, v)
                    v.facing_ref=v.facing
                    it = it + 1
                    flag=true
                end
            end
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()     
                G_FUNCS_draw_from_play_to_discard_ref(e)
            return true end)
          }))
       
    end

    local eval_card_ref=eval_card
    function eval_card(card, context) -- debuffed card won't call this
        local ret = eval_card_ref(card,context)
        G.GAME.scoring_hand=context.scoring_hand
        if context.cardarea == G.play and not context.repetition_only and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.GAME.used_vouchers.v_double_flipped_card and card.facing_ref=='back' then
            if (not card.shattered) and (not card.destroyed) then 
                draw_card_immediately(G.play,G.hand, 0.1,'down', false, card)
                card.facing_ref=card.facing
            end
        end
        return ret
    end
    
    function draw_card_immediately(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
        -- the value of hand is calculated immediately, and the animation takes time. The vanilla draw_card includes add_event which isn't immediate, but in eval_card we need to immediately move the double_flipped_card to hand so that in following calculation G.hand will include these cards.
        percent = percent or 50
        delay = delay or 0.1 
        if dir == 'down' then 
            percent = 1-percent
        end
        sort = sort or false
        local drawn = nil
        if card then 
            if from then card = from:remove_card(card) end
            if card then drawn = true end
            local stay_flipped = G.GAME and G.GAME.blind and G.GAME.blind:stay_flipped(to, card)
            if G.GAME.modifiers.flipped_cards and to == G.hand then
                if pseudorandom(pseudoseed('flipped_card')) < 1/G.GAME.modifiers.flipped_cards then
                    stay_flipped = true
                end
            end
            to:emplace(card, nil, stay_flipped)
        else
            if to:draw_card_from(from, stay_flipped, discarded_only) then drawn = true end
        end
        if not mute and drawn then
            if from == G.deck or from == G.hand or from == G.play or from == G.jokers or from == G.consumeables or from == G.discard then
                G.VIBRATION = G.VIBRATION + 0.6
            end
            play_sound('card1', 0.85 + percent*0.2/100, 0.6*(vol or 1))
        end
        if sort then
            to:sort()
        end
        return true
    end


end --
do 

    local name="Prologue"
    local id="prologue"
    local loc_txt = {
        name = "前言",
        text = {
            "盲注开局时",
            "生成一张{C:attention}永恒{C:tarot}塔罗牌",
            "{C:inactive}（必须有空间）",
            "该牌会在本奖券",
            "生成新牌前消失"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end

    local name="Epilogue"
    local id="epilogue"
    local loc_txt = {
        name = "后记",
        text = {
            "消耗牌槽位{C:attention}+1",
            "盲注结束时",
            "生成一张{C:attention}永恒{C:spectral}幻灵牌",
            "{C:inactive}（必须有空间）",
            "该牌会在本奖券",
            "生成新牌前消失"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=2},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_prologue'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Epilogue' then
            G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
        end
        Card_apply_to_run_ref(self, center)
    end

    local new_round_ref=new_round
    function new_round()
        if G.GAME.used_vouchers.v_prologue then
            for i=1,#G.consumeables.cards do
                if G.consumeables.cards[i].ability.v_prologue then
                    G.consumeables.cards[i]:start_dissolve(nil,nil)
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() randomly_create_tarot('v_prologue',nil,{eternal=true,extra_ability='v_prologue'}) return true end)
            }))
        end
        return new_round_ref()
    end

    local end_round_ref = end_round
    function end_round()
        for i=1,#G.consumeables.cards do
            if G.consumeables.cards[i].ability.v_epilogue then
                G.consumeables.cards[i]:start_dissolve(nil,nil)
            end
        end
        if G.GAME.used_vouchers.v_epilogue then
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() randomly_create_spectral('v_epilogue',nil,{eternal=true,extra_ability='v_epilogue'}) return true end)
            }))
            --,edition={negative=true}
        end
        end_round_ref()
    end
end --
do 

    local name="Bonus+"
    local id="bonus_plus"
    local loc_txt = {
        name = "奖励+",
        text = {
            "{C:blue}奖励牌{}的筹码加成",
            "永久{C:blue}+#1#",
            "{C:inactive}（例如：+30 -> +#2#）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=30},
        {x=0,y=0}, loc_txt,
        10, true, true, true
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra,self.config.extra+30}
    end

    local name="Mult+"
    local id="mult_plus"
    local loc_txt = {
        name = "倍率+",
        text = {
            "{C:red}倍率牌{}的倍率加成",
            "永久{C:red}+#1#",
            "{C:inactive}（例如：+4 -> +#2#）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=8},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_bonus_plus'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra,self.config.extra+4}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Bonus+' then
            G.P_CENTERS.m_bonus.config.bonus=G.P_CENTERS.m_bonus.config.bonus+G.P_CENTERS.v_bonus_plus.config.extra
        end
        if center_table.name == 'Mult+' then
            G.P_CENTERS.m_mult.config.mult=G.P_CENTERS.m_mult.config.mult+G.P_CENTERS.v_mult_plus.config.extra
        end
        Card_apply_to_run_ref(self, center)
    end

end --
 


    -- ################
    -- fusion vouchers!
    G.localization.misc.dictionary["k_fusion_voucher"] = "Fusion Voucher"
    if not G.ARGS.LOC_COLOURS then loc_colour() end
    if not G.ARGS.LOC_COLOURS["fusion"] then G.ARGS.LOC_COLOURS["fusion"] = HEX("F7D762") end
    local card_h_popupref = G.UIDEF.card_h_popup
    function G.UIDEF.card_h_popup(card)
        local retval = card_h_popupref(card)
        if not card.config.center or -- no center
        (card.config.center.unlocked == false and not card.bypass_lock) or -- locked card
        card.debuff or -- debuffed card
        (not card.config.center.discovered and ((card.area ~= G.jokers and card.area ~= G.consumeables and card.area) or not card.area)) -- undiscovered card
        then return retval end
        if card.ability.set=='Voucher' and card.config.center.mod_name=='Betmma Vouchers' and card.config.center.requires and #card.config.center.requires>1 then
            retval.nodes[1].nodes[1].nodes[1].nodes[3].nodes[1].nodes[1].nodes[2].config.object:remove()
            retval.nodes[1].nodes[1].nodes[1].nodes[3].nodes[1] = create_badge(localize('k_fusion_voucher'), loc_colour("fusion", nil), nil, 1.2)
        end

        return retval
    end


do 
    local name="Gold Round Up"
    local id="gold_round_up"
    local loc_txt = {
        name = "凑个整儿 黄金版",
        text = {
            "你的{C:money}资金{}永远",
            "向上取至最近的偶数值",
            "{C:inactive}（凑个整儿 + 金币）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_round_up','v_gold_coin'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end
    local ease_dollars_ref = ease_dollars
    function ease_dollars(mod, instant)
        if G.GAME.used_vouchers.v_gold_round_up and (G.GAME.dollars+mod) % 2 == 1 then
            mod=mod+1
        end
        ease_dollars_ref(mod, instant)
    end

end --
do 

    local name="Overshopping"
    local id="overshopping"
    local loc_txt = {
        name = "究极购物狂",
        text = {
            "跳过盲注后仍会进入商店",
            "{C:inactive}（库存过剩 + 供应过量）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_overstock_norm','v_oversupply'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end
    
    local G_FUNCS_skip_blind_ref=G.FUNCS.skip_blind
    G.FUNCS.skip_blind = function(e)
        G_FUNCS_skip_blind_ref(e)
        if G.GAME.used_vouchers.v_overshopping then
            --stop_use()
            -- from G.FUNCS.select_blind
            G.blind_select:remove()
            G.blind_prompt_box:remove()
            -- from cash_out()
            G.STATE = G.STATES.SHOP
            G.GAME.shop_free = nil
            G.GAME.shop_d6ed = nil
            G.STATE_COMPLETE = false
            G.GAME.current_round.reroll_cost_increase = 0
            -- from new_round()
            G.GAME.current_round.used_packs = {}
            local chaos = find_joker('Chaos the Clown')
            G.GAME.current_round.free_rerolls = #chaos
            calculate_reroll_cost(true)
            
            if G.GAME.used_vouchers.v_3d_boosters then
                my_reroll_shop(get_booster_pack_max()-2,0)
            end
            G:update_shop(dt)
        end
    end

end --
do 
    local name="Reroll Cut"
    local id="reroll_cut"
    local loc_txt = {
        name = name,
        text = {
            "Rerolling boss blind",
            "also rerolls tags, and",
            "gives a random tag",
            "{C:inactive}(Director's Cut + Reroll Surplus)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_directors_cut','v_reroll_surplus'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end

    local G_FUNC_can_reroll_ref=G.FUNCS.can_reroll
    G.FUNCS.can_reroll= function(e)
        G_FUNC_can_reroll_ref(e)
        if not(G.blind_prompt_box) then 
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
            --e.children[1].children[1].config.shadow = false
            --e.children[2].children[1].config.shadow = false
            --e.children[2].children[2].config.shadow = false
        end
    end

    local G_FUNC_reroll_boss_ref =  G.FUNCS.reroll_boss
    G.FUNCS.reroll_boss = function(e) 
        G_FUNC_reroll_boss_ref(e)
        
        if G.GAME.used_vouchers.v_reroll_cut then -- adding a pack tag when in a pack causes double pack and will crash
            stop_use()
            if G.GAME.round_resets.blind_states.Small ~= 'Defeated' then 
                G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
                --create_UIBox_blind_choice('Small', true)
            end
            if G.GAME.round_resets.blind_states.Big ~= 'Defeated' then 
                G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
                --create_UIBox_blind_choice('Big', true)
            end
            local random_tag_key = get_next_tag_key()
            while random_tag_key == 'tag_boss' do -- reroll boss tag will cause double blind select box
                random_tag_key = get_next_tag_key()
            end
            if not G.GAME.orbital_choices[G.GAME.round_resets.ante][type] then -- orbital tag
                local _poker_hands = {}
                for k, v in pairs(G.GAME.hands) do
                    if v.visible then _poker_hands[#_poker_hands+1] = k end
                end
            
                G.GAME.orbital_choices[G.GAME.round_resets.ante]['Small'] = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
              end
            local random_tag=Tag(random_tag_key,false,'Small')
        
            if G.blind_select then G.blind_select:remove()end
            G.blind_prompt_box:remove()
            G.blind_select = nil
            G.STATE_COMPLETE=false
            
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                func = (function() 
                    
                add_tag(random_tag)
                    return true end)
            }))
            --create_UIBox_blind_select()
        end
    end
end --
do 
    local name="Vanish Magic"
    local id="vanish_magic"
    local loc_txt = {
        name = name,
        text = {
            "You can make playing cards",
            "in the shop vanish and",
            "earn {C:money}$#1#{} for each",
            "{C:inactive}(Magic Trick + Blank)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=3},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_magic_trick','v_blank'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    G.FUNCS.vanish_card = function(e)
        local card = e.config.ref_table
        card:start_dissolve(nil,nil)
        ease_dollars(G.P_CENTERS.v_vanish_magic.config.extra)
    end
    
    G.FUNCS.can_vanish_card = function(e)
        e.config.colour = G.C.DARK_EDITION
        e.config.button = 'vanish_card'
    end
    G.localization.misc.dictionary.b_vanish = "VANISH"

    local Card_highlight_ref=Card.highlight
    function Card:highlight(is_higlighted)
        if self.area and self.area.config.type == 'shop' and (self.ability.set == 'Default' or self.ability.set == 'Enhanced') and G.GAME.used_vouchers.v_vanish_magic then
            -- if self.children.use_button then
            -- self.children.use_button:remove()
            -- self.children.use_button = nil
            -- end
            if 1 then
                local x_off = (self.ability.consumeable and -0.1 or 0)
                self.children.buy_button = UIBox{
                    definition = G.UIDEF.use_and_sell_buttons(self), 
                    config = {align=
                            ((self.area == G.jokers) or (self.area == G.consumeables)) and "cr" or
                            "bmi"
                        , offset = 
                            ((self.area == G.jokers) or (self.area == G.consumeables)) and {x=x_off - 0.4,y=0} or
                            {x=0,y=0.65},
                        parent =self}
                }
                local tst=self.children
            end
            --create_shop_card_ui(self)
            --return Card_highlight_ref(self,is_higlighted)
        end
        return Card_highlight_ref(self,is_higlighted)
    end

    local G_UIDEF_use_and_sell_buttons_ref=G.UIDEF.use_and_sell_buttons
    function G.UIDEF.use_and_sell_buttons(card)
        local retval = G_UIDEF_use_and_sell_buttons_ref(card)
        if card.area and card.area.config.type == 'shop' and (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.GAME.used_vouchers.v_vanish_magic then
            local buy={
            n=G.UIT.R, config = {ref_table = card, minw = 1.1, maxw = 1.3, padding = 0.1, align = 'bm', colour = G.C.GOLD, shadow = true, r = 0.08, minh = 0.94, func = 'can_buy', one_press = true, button = 'buy_from_shop', hover = true}, nodes={
                {n=G.UIT.T, config={text = localize('b_buy'),colour = G.C.WHITE, scale = 0.5}}
            }}
            local vanish = 
            {n=G.UIT.R, config={align = "bm"}, nodes={
            
            {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.GOLD, one_press = true, button = 'useless parameter lol', func = 'can_vanish_card'}, nodes={
                {n=G.UIT.B, config = {w=0.1,h=0.6}},
                {n=G.UIT.C, config={align = "tm"}, nodes={
                    {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={
                        {n=G.UIT.T, config={text = localize('b_vanish'),colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.T, config={text = '+'..localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
                        {n=G.UIT.T, config={ref_table = G.P_CENTERS.v_vanish_magic.config, ref_value = 'extra',colour = G.C.WHITE, scale = 0.55, shadow = true}}
                    }}
                }}
            }}
            }}
            retval.nodes[1].nodes[2].config.padding=-0.1
            retval.nodes[1].nodes[2].nodes = retval.nodes[1].nodes[2].nodes or {}
            table.insert(retval.nodes[1].nodes[2].nodes, buy)
            table.insert(retval.nodes[1].nodes[2].nodes, vanish)
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            table.insert(retval.nodes[1].nodes[2].nodes, {n=G.UIT.R, config = {align = "bm", w=7.7*card.T.w}})
            return retval
        end
        return retval
    end
    
end --
do 
    local name="Darkness"
    local id="darkness"
    local loc_txt = {
        name = "暗物质",
        text = {
            "{C:dark_edition}负片{}牌出现频率{C:attention}X#1#",
            "{C:inactive}（焕彩 + 反物质）"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=4},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_glow_up','v_antimatter'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local poll_edition_ref=poll_edition
    function poll_edition(_key, _mod, _no_neg, _guaranteed)
        _mod=_mod or 1
        if G.GAME.used_vouchers.v_darkness then
            local ret=poll_edition_ref(_key, _mod*(G.P_CENTERS.v_darkness.config.extra-1), _no_neg, _guaranteed)
            if ret and ret.negative then
                return ret
            end
        end
        return poll_edition_ref(_key, _mod, _no_neg, _guaranteed)
    end

end --
do
    local name="Double Planet"
    local id="double_planet"
    local loc_txt = {
        name = name,
        text = {
            "Create a random {C:planet}Planet{} card",
            "when buying a Planet card",
            "{C:inactive}(Must have room)",
            "{C:inactive}(Planet Merchant + B1G50%)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_planet_merchant','v_b1g50'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {}
    end

    local G_FUNCS_buy_from_shop_ref=G.FUNCS.buy_from_shop
    G.FUNCS.buy_from_shop = function(e)
        local c1 = e.config.ref_table
        local ret=G_FUNCS_buy_from_shop_ref(e)
        if c1.ability.consumeable and (c1.config.center.set == 'Planet') and ret~=false and G.GAME.used_vouchers.v_double_planet and #G.consumeables.cards + G.GAME.consumeable_buffer + 1 < G.consumeables.config.card_limit then -- +1 is because buy_from_shop adds a card in an event that is executed after this code
            randomly_create_planet('v_double_planet','Double Planet!',nil)
        end
    end
end --
do
    local name="Trash Picker"
    local id="trash_picker"
    local loc_txt = {
        name = name,
        text = {
            "{C:blue}+#1#{} hand and {C:red}+#1#{} discard per round.",
            "You can spend 1 hand to discard",
            "if you have no discards.",
            "Each discard gives {C:money}$1{} after rounds",
            "{C:inactive}(Grabber + Wasteful)"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_grabber','v_wasteful'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Trash Picker' then
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + center_table.extra
            ease_hands_played(center_table.extra)
            G.GAME.round_resets.discards = G.GAME.round_resets.discards + center_table.extra
            ease_discard(center_table.extra)
            G.GAME.modifiers.money_per_discard = (G.GAME.modifiers.money_per_discard or 0) +1
        end
        Card_apply_to_run_ref(self, center)
    end
    
    local G_FUNCS_can_discard_ref=G.FUNCS.can_discard
    G.FUNCS.can_discard = function(e)
        G_FUNCS_can_discard_ref(e)
        if G.GAME.current_round.discards_left <= 0 and #G.hand.highlighted > 0 and G.GAME.used_vouchers.v_trash_picker and G.GAME.current_round.hands_left>1 then
            e.config.colour = G.C.RED
            e.config.button = 'discard_cards_from_highlighted_using_hand'
        end
    end

    local G_FUNCS_discard_cards_from_highlighted_ref = G.FUNCS.discard_cards_from_highlighted 
    G.FUNCS.discard_cards_from_highlighted_using_hand = function(e, hook)
        G_FUNCS_discard_cards_from_highlighted_ref(e,hook)
        ease_hands_played(-1)
    end
end --
do
    local name="Money Target"
    local id="money_target"
    local loc_txt = {
        name = name,
        text = {
            "Earn double {C:money}interest{}", 
            "at end of round if your",
            "money is multiples of 5",
            "{C:inactive}(Seed Money + Target){}"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=2},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_seed_money','v_target'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local G_FUNCS_evaluate_round_ref=G.FUNCS.evaluate_round
    G.FUNCS.evaluate_round = function()
        G.GAME.interest_amount_ref=G.GAME.interest_amount
        --print("interest_ref",G.GAME.interest_amount_ref)
        G.GAME.v_money_target_triggered=false
        if G.GAME.used_vouchers.v_money_target and G.GAME.dollars%5==0 then
            G.GAME.v_money_target_triggered=true
            G.GAME.interest_amount=G.GAME.interest_amount*G.P_CENTERS.v_money_target.config.extra
        end
        --print("interest",G.GAME.interest_amount)
        G_FUNCS_evaluate_round_ref()
    end

    
    local G_FUNCS_cash_out_ref=G.FUNCS.cash_out
    G.FUNCS.cash_out=function (e)
        if G.GAME.used_vouchers.v_money_target and G.GAME.v_money_target_triggered then
            local delta= G.GAME.interest_amount-G.GAME.interest_amount_ref*G.P_CENTERS.v_money_target.config.extra -- if delta ~= 0 then jokers adding amount were sold between evaluate_round and cash_out
            --print("delta",delta)
            G.GAME.interest_amount=G.GAME.interest_amount_ref+delta
        end
        G_FUNCS_cash_out_ref(e)
    end
end --
do
    local name="Art Gallery"
    local id="art_gallery"
    local loc_txt = {
        name = name,
        text = {
            "{C:attention}+#1#{} Ante to win.",
            "When {C:attention}Boss Blind{} is defeated,", 
            "randomly get one of the following:",
            "{C:blue}+#1#{} hand, {C:red}+#1#{} discard or {C:attention}-#1#{} Ante",
            "{C:inactive}(Hieroglyph + Abstract Art){}"
        }
    }
    local this_v = SMODS.Voucher:new(
        name, id,
        {extra=1},
        {x=0,y=0}, loc_txt,
        10, true, true, true, {'v_hieroglyph','v_abstract_art'}
    )
    SMODS.Sprite:new("v_"..id, SMODS.findModByID("BetmmaVouchers").path, "v_"..id..".png", 71, 95, "asset_atli"):register();
    this_v:register()
    this_v.loc_def = function(self)
        return {self.config.extra}
    end

    local Card_apply_to_run_ref = Card.apply_to_run
    function Card:apply_to_run(center)
        local center_table = {
            name = center and center.name or self and self.ability.name,
            extra = center and center.config.extra or self and self.ability.extra
        }
        if center_table.name == 'Art Gallery' then
            ease_ante_to_win(center_table.extra)
        end
        Card_apply_to_run_ref(self, center)
    end

    local end_round_ref = end_round
    function end_round()
        if G.GAME.used_vouchers.v_art_gallery and G.GAME.blind:get_type() == 'Boss' then
            local random_number=pseudorandom('v_art_gallery')
            local value=G.P_CENTERS.v_art_gallery.config.extra
            if random_number < 1/3 then
                G.GAME.round_resets.hands = G.GAME.round_resets.hands + value
                ease_hands_played(value)
            elseif random_number < 2/3 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards + value
                ease_discard(value)
            else
                ease_ante(-value)
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante-value
            end
            
        end
        end_round_ref()
    end
end --
    -- -- this challenge is only for test
    -- table.insert(G.CHALLENGES,1,{
    --     name = "TestVoucher",
    --     id = 'c_mod_testvoucher',
    --     rules = {
    --         custom = {
    --         },
    --         modifiers = {
    --             {id = 'dollars', value = 5},
    --         }
    --     },
    --     jokers = {
    --         --{id = 'j_jjookkeerr'},
    --         -- {id = 'j_ascension'},
    --         {id = 'j_hasty'},
    --         -- {id = 'j_dna'},
    --         -- {id = 'j_mime'},
    --         -- {id = 'j_piggy_bank'},
    --         -- {id = 'j_blueprint'},
    --         {id = 'j_triboulet'},
    --     },
    --     consumeables = {
    --         -- {id = 'c_death'},
    --     },
    --     vouchers = {
    --         {id = 'v_trash_picker'},
    --         {id = 'v_money_target'},
    --         {id = 'v_bonus_plus'},
    --         {id = 'v_mult_plus'},
    --         -- {id = 'v_vanish_magic'},
    --         -- {id = 'v_liquidation'},
    --         -- {id = 'v_3d_boosters'},
    --         -- {id = 'v_b1g1'},
    --         -- {id = 'v_overshopping'},
    --         -- {id = 'v_directors_cut'},
    --         -- {id = 'v_retcon'},
    --         -- {id = 'v_event_horizon'},
    --     },
    --     deck = {
    --         type = 'Challenge Deck',
    --         -- cards = {{s='D',r='2',e='m_steel',g='Red'},{s='D',r='3',e='m_steel',g='Red'},{s='D',r='4',e='m_steel',g='Red'},{s='D',r='5',e='m_steel',g='Red'},{s='D',r='6',e='m_steel',g='Red'},{s='D',r='7',e='m_steel',},{s='D',r='8',e='m_steel',},{s='D',r='9',e='m_steel',},{s='D',r='T',e='m_steel',},{s='D',r='J',e='m_steel',},{s='D',r='Q',e='m_steel',},{s='D',r='K',e='m_steel',},{s='D',r='A',e='m_steel',},}
    --     },
    --     restrictions = {
    --         banned_cards = {
    --         },
    --         banned_tags = {
    --         },
    --         banned_other = {
    --         }
    --     }
    -- })
    -- G.localization.misc.challenge_names.c_mod_testvoucher = "TestVoucher"
    init_localization()
end
----------------------------------------------
------------MOD CODE END----------------------
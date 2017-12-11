--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local GameLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.GameLayer")
local CardExtractor = class("CardExtractor", function(scene)
	local CardExtractor = display.newLayer()
	return CardExtractor
end)

function CardExtractor:ctor(scene)
	self._scene = scene
	self:onInitData()
	local this = self

end

function CardExtractor:onInitData()
end

function CardExtractor:onResetData()
end

--扑克图片
function CardExtractor:create_CCardListImage(base)
    return CCardListImage:create(base):addTo(base)
end

--===================================================================
--扑克图片
function CCardListImage:ctor(scene)
end


--------------------------------------------------------------

return CardExtractor

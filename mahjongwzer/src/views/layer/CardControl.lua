--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local CardControl = class("CardControl", function(scene)
	local CardControl = display.newLayer()
	return CardControl
end)
--扑克图片
local CCardListImage = class("CCardListImage", cc.Layer)
--扑克资源
local CCardResource = class("CCardResource", cc.Layer)
--堆立扑克
local CHeapCard = class("CHeapCard", cc.Layer)
--组合扑克
local CWeaveCard = class("CWeaveCard", cc.Layer)
--用户扑克
local CUserCard = class("CUserCard", cc.Layer)
--丢弃扑克
local CDiscardCard = class("CDiscardCard", cc.Layer)
--桌面扑克
local CTableCard = class("CTableCard", cc.Layer)
--扑克控件
local CCardControl = class("CCardControl", cc.Layer)

CardControl.HEAP_FULL_COUNT		= 34								--开始按钮
--公共定义
CardControl.POS_SHOOT					= 5									--弹起象素
CardControl.POS_SPACE					= 16								--分隔间隔
CardControl.ITEM_COUNT				=	43								--子项数目
CardControl.INVALID_ITEM			=	0xFFFF						--无效索引

--扑克大小
CardControl.CARD_WIDTH				=	45								--扑克宽度 39
CardControl.CARD_HEIGHT				=	69								--扑克高度  64

function CardControl:ctor(scene)
	self._scene = scene
	self:onInitData()
	local this = self
end

function CardControl:onInitData()
end

function CardControl:onResetData()
end

--扑克图片
function CardControl:create_CCardListImage(base)
    return CCardListImage:create(base):addTo(base)
end
--扑克资源
function CardControl:create_CCardResource(base)
    return CCardResource:create(base):addTo(base)
end
--堆立扑克
function CardControl:create_CHeapCard(base)
    return CHeapCard:create(base):addTo(base)
end
--组合扑克
function CardControl:create_CWeaveCard(base)
    return CWeaveCard:create(base):addTo(base)
end
--用户扑克
function CardControl:create_CUserCard(base)
    return CUserCard:create(base):addTo(base)
end
--丢弃扑克
function CardControl:create_CDiscardCard(base)
    return CDiscardCard:create(base):addTo(base)
end
--桌面扑克
function CardControl:create_CTableCard(base)
    return CTableCard:create(base):addTo(base)
end
--扑克控件
function CardControl:create_CCardControl(base)
    return CCardControl:create(base):addTo(base)
end

--===================================================================
--扑克图片
function CCardListImage:ctor(scene)
	--位置变量
	CCardListImage.m_nItemWidth=0
	CCardListImage.m_nItemHeight=0
	CCardListImage.m_nViewWidth=0
	CCardListImage.m_nViewHeight=0
	return
end

--===================================================================
--扑克资源
function CCardResource:ctor(scene)
end

--===================================================================
--堆立扑克
function CHeapCard:ctor(scene)
end

--===================================================================
--组合扑克
function CWeaveCard:ctor(scene)
end

--===================================================================
--用户扑克
function CUserCard:ctor(scene)
end

--===================================================================
--丢弃扑克
function CDiscardCard:ctor(scene)
end

--===================================================================
--桌面扑克
function CTableCard:ctor(scene)
end

--===================================================================
--扑克控件
function CCardControl:ctor(scene)
end


--------------------------------------------------------------

return CardControl

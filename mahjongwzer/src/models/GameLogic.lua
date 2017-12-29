local GameLogic = {}

--local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--逻辑掩码

GameLogic.MASK_COLOR		=			0xF0								--花色掩码
GameLogic.MASK_VALUE		=			0x0F								--数值掩码

--------------------------------------------------------------------------
--动作定义

--动作标志
GameLogic.WIK_NULL			=		0x00								--没有类型
GameLogic.WIK_LEFT			=		0x01								--左吃类型
GameLogic.WIK_CENTER		=		0x02								--中吃类型
GameLogic.WIK_RIGHT			=		0x04								--右吃类型
GameLogic.WIK_PENG			=		0x08								--碰牌类型
GameLogic.WIK_GANG			=		0x10								--杠牌类型
GameLogic.WIK_LISTEN		=		0x20								--听牌类型
GameLogic.WIK_CHI_HU		=		0x40								--吃胡类型

--------------------------------------------------------------------------
--胡牌定义

--牌型掩码
GameLogic.CHK_MASK_SMALL=				0x0000FFFF							--小胡掩码
GameLogic.CHK_MASK_GREAT=				0xFFFF0000							--大胡掩码

--小胡牌型
GameLogic.CHK_NULL			=				0x00000000							--非胡类型
GameLogic.CHK_JI_HU			=				0x00000001							--鸡胡类型
GameLogic.CHK_PING_HU		=				0x00000002							--平胡类型

--大胡牌型
GameLogic.CHK_PENG_PENG	 =			0x00010000							--碰碰胡牌
GameLogic.CHK_QI_XIAO_DUI=			0x00020000							--七小对牌
GameLogic.CHK_SHI_SAN_YAO=			0x00040000							--十三幺牌
GameLogic.CHK_YING_PAI	 =			0x00080000							--硬牌
GameLogic.CHK_SAN_GODS	 =			0x00100000							--三财神
GameLogic.CHK_SINGLE_PAI =      0x00200000              -- 单张胡牌
GameLogic.CHK_BA_DUI     =      0x00400000              -- 八对
GameLogic.CHK_YING_BA_DUI=      0x00800000              -- 硬八对


--------------------------------------------------------------------------
--胡牌权位

--牌权掩码
GameLogic.CHR_MASK_SMALL	=			0x000000FF							--小胡掩码
GameLogic.CHR_MASK_GREAT	=			0xFFFFFF00							--大胡掩码

--大胡权位
GameLogic.CHR_DI					=			0x00000100							--地胡权位
GameLogic.CHR_TIAN				=			0x00000200							--天胡权位
GameLogic.CHR_QING_YI_SE	=			0x00000400							--清一色牌
GameLogic.CHR_QIANG_GANG	=			0x00000800							--抢杆权位
GameLogic.CHK_QUAN_QIU_REN=			0x00001000							--全求权位
--------------------------------------------------------------------------

--类型子项
GameLogic.tagKindItem=
{
	{k = "cbWeaveKind", t = "byte"},					--组合类型
	{k = "cbCenterCard", t = "byte"},					--中心扑克
	{k = "cbCardIndex", t = "byte",l = {3}} 	--扑克索引
}

--组合子项
GameLogic.tagWeaveItem=
{
	{k = "cbWeaveKind", t = "byte"},					--组合类型
	{k = "cbCenterCard", t = "byte"},					--中心扑克
	{k = "cbPublicCard", t = "byte"},					--公开标志
	{k = "wProvideUser", t = "word"}					--供应用户
}

--胡牌结果
GameLogic.tagChiHuResult=
{
	{k = "dwChiHuKind", t = "dword"},					--吃胡类型
	{k = "dwChiHuRight", t = "dword"},				--胡牌权位
	{k = "dwWinTimes", t = "dword"}						--番数数目
}

--杠牌结果
GameLogic.tagGangCardResult=
{
	{k = "cbCardCount", t = "byte"},					--扑克数目
	{k = "cbCardData", t = "byte",l = {4}},		--扑克数据
	{k = "cbGangType", t = "byte"}						--杠牌类型
}

--分析子项
GameLogic.tagAnalyseItem=
{
	{k = "cbCardEye", t = "byte"},						--牌眼扑克
	{k = "cbWeaveKind", t = "byte",l = {cmd.MAX_WEAVE}},			--组合类型
	{k = "cbCenterCard", t = "byte" ,l = {cmd.MAX_WEAVE}}		--中心扑克
}

GameLogic.BAIBAN_CARD_DATA  = 0x37   -- 白板

GameLogic.m_byGodsCardData = 0x00  -- 财神

--------------------------------------------------------------------------

--数组说明
--typedef CWHArray<tagAnalyseItem,tagAnalyseItem &> CAnalyseItemArray;

--------------------------------------------------------------------------
--静态变量

--扑克数据
GameLogic.m_cbCardDataArray=
{
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 						--万子
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 						--万子
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 						--万子
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 						--万子
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 						--索子
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 						--索子
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 						--索子
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 						--索子
	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 						--同子
	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 						--同子
	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 						--同子
	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 						--同子
	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 									--番子
	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 									--番子
	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 									--番子
	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 									--番子
}

--拷贝数组
function GameLogic:deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
				--
        -- elseif lookup_table[object] then
        --     return lookup_table[object]
        end  -- if
        local new_table = {}
        lookup_table[object] = new_table

        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--table 的长度
function GameLogic:table_leng(t)
  if not t  and type(t)~="table" then print("table_leng 数据类型错误") return end
  local leng=0
  for k, v in pairs(t) do
    leng=leng+1
  end
  return leng
end
--CWHArray append  PS 当键名不是数字的时候 中间键名可能不连续  并且其实为1不是0 table_leng换# 时为连续
function GameLogic:append(a,b)
	local c=GameLogic:table_leng(a)
	for i=1,GameLogic:table_leng(b),1 do
		a[c+i]=b[i]
	end
	--return a
end
--CWHArray add  不建方法SetAtGrow
function GameLogic:add(m_pData,newElement)
	local nIndex=GameLogic:table_leng(m_pData)
	m_pData[nIndex+1]=newElement
	--return m_pData
end

--ZeroMemory
function GameLogic:ergodicList(b)
	a={}
	for i=1,b,1 do
		a[i]={}
	end
	return a
end
function GameLogic:sizeM(b)
	a={}
	for i=1,b,1 do
		a[i]=0
	end
	return a
end

function GameLogic:Draw3dRect(x, y, cx, cy,	clrTopLeft, clrBottomRight)
	self:FillSolidRect(x, y, cx - 1, 1, clrTopLeft)
	self:FillSolidRect(x, y, 1, cy - 1, clrTopLeft)
	self:FillSolidRect(x + cx, y, -1, cy, clrBottomRight)
	self:FillSolidRect(x, y + cy, cx, -1, clrBottomRight)
end

function GameLogic:FillSolidRect(x, y, cx, cy, color)
  local dr=cc.DrawNode:create()
    :setPosition(cc.p(x+cx/2,y+cy/2))
    :drawSolidRect(cc.p(x,y), cc.p(x+cx,y+cy), color)
		:setAnchorPoint(cc.p(0.5,0.5))
		:addTo(self)
	return dr
end

--遮罩
function GameLogic:Clipp9S(fileb,sWidth,sHeight)
	local filestr = "res/game/mask.png" 
	if false == cc.FileUtils:getInstance():isFileExist(fileb) then print("fileb is no Exist") return	end
	if false == cc.FileUtils:getInstance():isFileExist(filestr) then print("filestr is no Exist") return	end
	local bg=display.newSprite(fileb)
		:setTag(1)
		:setAnchorPoint(cc.p(0,0.5))
		:move(0,0)
		
    local clipSp = cc.Scale9Sprite:create(filestr)
        :setCapInsets(CCRectMake(1,1,49,49))
        :setContentSize(cc.size(sWidth, sHeight))
        :move(0,0)
    
	local clip = cc.ClippingNode:create()
		clip:setStencil(clipSp)
		clip:setAlphaThreshold(0)
		clip:addChild(bg)
	return clip
end  

--混乱扑克
function GameLogic:RandCardData(cbCardData,cbMaxCount,userid)	--这个里面的随机要加二个用户的userid之合，不然会牌一样的
	--混乱准备
	local cbCardDataTemp=GameLogic:deepcopy(GameLogic.m_cbCardDataArray)

	--初始化种子   客户端不需要？
	--math.randomseed(os.time()+userid)

	--混乱扑克
	local cbRandCount,cbPosition=0,0
	cbPosition=math.random()%(cbMaxCount-cbRandCount)
	cbRandCount=cbRandCount+1
	cbCardData[cbRandCount]=cbCardDataTemp[cbPosition]
	cbCardDataTemp[cbPosition]=cbCardDataTemp[cbMaxCount-cbRandCount]
	while(cbRandCount<cbMaxCount)
	do
			cbPosition=math.random()%(cbMaxCount-cbRandCount)
			cbRandCount=cbRandCount+1
			cbCardData[cbRandCount]=cbCardDataTemp[cbPosition]
			cbCardDataTemp[cbPosition]=cbCardDataTemp[cbMaxCount-cbRandCount]
	end

	return
end

--删除扑克
--CGameLogic::RemoveCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard)
--											(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard[], BYTE cbRemoveCount)
--											(BYTE cbCardData[], BYTE cbCardCount, BYTE cbRemoveCard[], BYTE cbRemoveCount)

function GameLogic:RemoveCard(...)
	local arg={...}
	local len=#arg
	if len==2 then	return GameLogic:RemoveCard_2(arg[1],arg[2])
	elseif len==3 then	return GameLogic:RemoveCard_3(arg[1],arg[2],arg[3])
	elseif len==4 then	return GameLogic:RemoveCard_4(arg[1],arg[2],arg[3],arg[4])
	else	print("RemoveCard 参数个数不符合")
	end
end

--====   RemoveCard2
function GameLogic:RemoveCard_2(cbCardIndex,cbRemoveCard)
	--效验扑克
	-- ASSERT(IsValidCard(cbRemoveCard));
	-- ASSERT(cbCardIndex[SwitchToCardIndex(cbRemoveCard)]>0);
	--删除扑克
	local cbRemoveIndex=GameLogic:SwitchToCardIndex(cbRemoveCard)
	if cbCardIndex[cbRemoveIndex]>0 then
		cbCardIndex[cbRemoveIndex]=cbCardIndex[cbRemoveIndex]-1
		return true
	end
	return false
end

--====   RemoveCard3
function GameLogic:RemoveCard_3(cbCardIndex,cbRemoveCard,cbRemoveCount)
	--删除扑克
	for i=1,cbRemoveCount,1 do
		--效验扑克
		--ASSERT(IsValidCard(cbRemoveCard[i]));
		--ASSERT(cbCardIndex[SwitchToCardIndex(cbRemoveCard[i])]>0);

		--删除扑克
		local cbRemoveIndex=GameLogic:SwitchToCardIndex(cbRemoveCard[i])
		--变相continue
  	while true do
			if cbCardIndex[cbRemoveIndex]==0 then

				--还原删除
				for j=1,i,1 do
					--ASSERT(IsValidCard(cbRemoveCard[j]))
					cbCardIndex[GameLogic:SwitchToCardIndex(cbRemoveCard[j])]=cbCardIndex[GameLogic:SwitchToCardIndex(cbRemoveCard[j])]+1
				end
				break
			-- else
			-- 	--删除扑克
			-- 	--cbCardIndex[cbRemoveIndex];
			-- 	break
			end
			break
    end
	end
	return true
end

--====   RemoveCard4
function GameLogic:RemoveCard_4(cbCardData,cbCardCount,cbRemoveCard,cbRemoveCount)
	--检验数据
	-- ASSERT(cbCardCount<=MAX_COUNT);
	-- ASSERT(cbRemoveCount<=cbCardCount);

	--定义变量
	local cbDeleteCount,cbTempCardData =0,{}
	if cbCardCount>cmd.MAX_COUNT then
		return false
	end
	--问题mark 不确定
	--CopyMemory(cbTempCardData,cbCardData,cbCardCount*sizeof(cbCardData[0]));
	local cbTempCardData=GameLogic:deepcopy(cbCardData)

	--置零扑克
	for i=1,cbRemoveCount,1 do
		while true do
			for j=1,cbCardCount,1 do
				if cbRemoveCard[i]==cbTempCardData[j] then
					cbDeleteCount=cbDeleteCount+1
					cbTempCardData[j]=0
				break	end
			end
		break	end
	end

	--成功判断
	if cbDeleteCount~=cbRemoveCount then
		--ASSERT(FALSE);
		return false
	end

	--清理扑克
	local cbCardPos = 0
	for i=1,cbCardCount,1 do
		if cbTempCardData[i]~=0 then
			cbCardPos=cbCardPos+1
			cbCardData[cbCardPos]=cbTempCardData[i];
		end
	end

	return true
end

--有效判断
function GameLogic:IsValidCard(cbCardData)
	local cbValue = bit:_and(cbCardData, GameLogic.MASK_VALUE)
	local cbColor = bit:_rshift(bit:_and(cbCardData, GameLogic.MASK_COLOR),4)
	return (((cbValue>=1)and(cbValue<=9)and(cbColor<=2))or((cbValue>=1)and(cbValue<=7)and(cbColor==3)))
end

--扑克数目
function GameLogic:GetCardCount(cbCardIndex)
	local cbCardCount = 0
	for i=1,cmd.MAX_COUNT,1 do
		cbCardCount=cbCardCount+cbCardIndex[i]
	end
	return cbCardCount;
end

--获取组合
function GameLogic:GetWeaveCard(cbWeaveKind,cbCenterCard,cbCardBuffer)
	--组合扑克
	local switch = {
	    [GameLogic.WIK_LEFT] = function()    -- 上牌操作
					--设置变量
					if GameLogic.BAIBAN_CARD_DATA == cbCenterCard then
						cbCenterCard = GameLogic.m_byGodsCardData
					end
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard+1
					cbCardBuffer[3]=cbCenterCard+2
					for i=1, i<3, 1 do
						if GameLogic.m_byGodsCardData == cbCardBuffer[i] then
							cbCardBuffer[i]=GameLogic.BAIBAN_CARD_DATA
						end
					end
					return 3
	    end,
	    [GameLogic.WIK_RIGHT] = function()    --上牌操作
					--设置变量
					if GameLogic.BAIBAN_CARD_DATA == cbCenterCard then
						cbCenterCard = GameLogic.m_byGodsCardData
					end
					cbCardBuffer[1]=cbCenterCard-2
					cbCardBuffer[2]=cbCenterCard-1
					cbCardBuffer[3]=cbCenterCard
					for i=1, i<3, 1 do
						if GameLogic.m_byGodsCardData == cbCardBuffer[i] then
							cbCardBuffer[i]=GameLogic.BAIBAN_CARD_DATA
						end
					end
					return 3
	    end,
	    [GameLogic.WIK_CENTER] = function()    --上牌操作
					--设置变量
					if GameLogic.BAIBAN_CARD_DATA == cbCenterCard then
						cbCenterCard = GameLogic.m_byGodsCardData
					end
					cbCardBuffer[1]=cbCenterCard-1
					cbCardBuffer[2]=cbCenterCard
					cbCardBuffer[3]=cbCenterCard+1
					for i=1, i<3, 1 do
						if GameLogic.m_byGodsCardData == cbCardBuffer[i] then
							cbCardBuffer[i]=GameLogic.BAIBAN_CARD_DATA
						end
					end
					return 3
	    end,
	    [GameLogic.WIK_PENG] = function()    --碰牌操作
					--设置变量
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard
					cbCardBuffer[3]=cbCenterCard

					return 3
	    end,
	    [GameLogic.WIK_GANG] = function()    --杠牌操作
					--设置变量
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard
					cbCardBuffer[3]=cbCenterCard
					cbCardBuffer[4]=cbCenterCard

					return 4
	    end
	}

	local f = switch[cbWeaveKind]
	if(f) then
	    f()
	else   									-- for case default
			--ASSERT(FALSE)
	    print "Case default."
	end

	return 0
end

--动作等级
function GameLogic:GetUserActionRank(cbUserAction)
	--胡牌等级
	if bit:_and(cbUserAction, GameLogic.WIK_CHI_HU) then  return 4 end

	--杠牌等级
	if bit:_and(cbUserAction, GameLogic.WIK_GANG) then  return 3 end

	--碰牌等级
	if bit:_and(cbUserAction, GameLogic.WIK_PENG) then  return 2 end

	--上牌等级
	if bit:_and(cbUserAction, (bit:_or(bit:_or(GameLogic.WIK_RIGHT,GameLogic.WIK_CENTER),GameLogic.WIK_LEFT))) then  return 1 end

	return 0
end

--胡牌等级 					GameLogic.tagChiHuResult
function GameLogic:GetChiHuActionRank(ChiHuResult)
	return 0
end

--吃牌判断
function GameLogic:EstimateEatCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard))

		-- 财神不可以吃
		if cbCurrentCard == GameLogic.m_byGodsCardData then
			return GameLogic.WIK_NULL
		end

		--过滤判断
		--番子无连
		if (cbCurrentCard>= 0x31) and (GameLogic.BAIBAN_CARD_DATA ~= cbCurrentCard) then
			return GameLogic.WIK_NULL
		end
		if (cbCurrentCard>= 0x31) and ((GameLogic.BAIBAN_CARD_DATA == cbCurrentCard) and (GameLogic.m_byGodsCardData>= 0x31)) then
			return GameLogic.WIK_NULL
		end

		--变量定义
		local cbExcursion={0,1,2}
		local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT}

		--吃牌判断
		local cbEatKind,cbFirstIndex=0,0
		local cbCurrentIndex=GameLogic:SwitchToCardIndex(cbCurrentCard)
		if cbCurrentIndex > 27  then
			return GameLogic.WIK_NULL
		end

		for i=1,GameLogic:table_leng(cbItemKind),1 do
				local cbValueIndex=cbCurrentIndex%9
				while (cbValueIndex>=cbExcursion[i]) and ((cbValueIndex-cbExcursion[i])<=6) do
						--吃牌判断
						cbFirstIndex=cbCurrentIndex-cbExcursion[i]
						if (cbCurrentIndex~=cbFirstIndex) and (cbCardIndex[cbFirstIndex]==0) then  break	end

						if (cbCurrentIndex~=(cbFirstIndex+1)) and (cbCardIndex[cbFirstIndex+1]==0) then  break	end

						if (cbCurrentIndex~=(cbFirstIndex+2)) and (cbCardIndex[cbFirstIndex+2]==0) then break	end

						--设置类型
						cbEatKind=bit:_or(cbEatKind,cbItemKind[i])
				break	end
		end

		return cbEatKind
end

--碰牌判断
function GameLogic:EstimatePengCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard))

	--碰牌判断
	return (cbCardIndex[GameLogic:SwitchToCardIndex(cbCurrentCard)]>=2) and GameLogic.WIK_PENG or GameLogic.WIK_NULL
end

--杠牌判断
function GameLogic:EstimateGangCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard));

	--杠牌判断
	return (cbCardIndex[GameLogic:SwitchToCardIndex(cbCurrentCard)]==3) and GameLogic.WIK_GANG or GameLogic.WIK_NULL
end

--听牌分析
function GameLogic:AnalyseTingCard(cbCardIndex, WeaveItem,cbItemCount,dwChiHuRight)
	-- 温州麻将没有听牌功能
	----变量定义
	--tagChiHuResult ChiHuResult;
	--ZeroMemory(&ChiHuResult,sizeof(ChiHuResult));

	----构造扑克
	--BYTE cbCardIndexTemp[MAX_INDEX];
	--CopyMemory(cbCardIndexTemp,cbCardIndex,sizeof(cbCardIndexTemp));

	----听牌分析
	--for (BYTE i=0;i<MAX_INDEX;i++)
	--{
	--	--空牌过滤
	--	if (cbCardIndexTemp[i]==0)
	--		continue;

	--	--听牌处理
	--	cbCardIndexTemp[i]--;

	--	--听牌判断
	--	for (BYTE j=0;j<MAX_INDEX;j++)
	--	{
	--		--胡牌分析
	--		BYTE cbCurrentCard=SwitchToCardData(j);
	--		BYTE cbHuCardKind=AnalyseChiHuCard(cbCardIndexTemp,WeaveItem,cbItemCount,cbCurrentCard,dwChiHuRight,ChiHuResult);

	--		--结果判断
	--		if (cbHuCardKind!=CHK_NULL)
	--			return WIK_LISTEN;
	--	}

	--	--还原处理
	--	cbCardIndexTemp[i]++;
	--}

	return GameLogic.WIK_NULL
end

--杠牌分析    GameLogic.tagWeaveItem WeaveItem   --   GameLogic.tagGangCardResult GangCardResult
function GameLogic:AnalyseGangCard(cbCardIndex,WeaveItem,cbWeaveCount,GangCardResult)
	--设置变量
	local cbActionMask= GameLogic.WIK_NULL
	--问题mark 不确定 GangCardResult结构体 暂为写到调用改方法 临时跳过   下同 LSTG   确保 GangCardResult有效
	--ZeroMemory(&GangCardResult,sizeof(GangCardResult))
	--GangCardResult=nil
	GangCardResult={}

	--手上杠牌
	for i=1,cmd.MAX_INDEX,1 do
		if cbCardIndex[i]==4 then
			cbActionMask=bit:_or(cbActionMask,GameLogic.WIK_GANG)
			if GangCardResult.cbCardCount then print("!!!AnalyseGangCard GangCardResult.cbCardCount 不能为nil") return end
			GangCardResult.cbCardData[GangCardResult.cbCardCount]=GameLogic.WIK_GANG
			GangCardResult.cbCardCount=GangCardResult.cbCardCount+1
			GangCardResult.cbCardData[GangCardResult.cbCardCount]=GameLogic:SwitchToCardData(i)
		end
	end

	--组合杠牌
	for i=1,cbWeaveCount,1 do
		if WeaveItem[i].cbWeaveKind==GameLogic.WIK_PENG then
			if cbCardIndex[GameLogic:SwitchToCardIndex(WeaveItem[i].cbCenterCard)]==1 then
				cbActionMask=bit:_or(cbActionMask,GameLogic.WIK_GANG)

				GangCardResult.cbCardData[GangCardResult.cbCardCount]=GameLogic.WIK_GANG
				GangCardResult.cbCardCount=GangCardResult.cbCardCount+1
				GangCardResult.cbCardData[GangCardResult.cbCardCount]=WeaveItem[i].cbCenterCard
			end
		end
	end

	return cbActionMask
end

--吃胡分析
function GameLogic:AnalyseChiHuCard(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard,dwChiHuRight,tagChiHuResult,ChiHuResult)
	--变量定义
	local dwChiHuKind=GameLogic.CHK_NULL
	local AnalyseItemArray

	--设置变量
	--ZeroMemory(&ChiHuResult,sizeof(ChiHuResult))
	--ChiHuResult=nil					--待确认是否合理
	ChiHuResult={}

	--构造扑克
	local cbCardIndexTemp=GameLogic:deepcopy(cbCardIndex)

	--插入扑克
	if cbCurrentCard~=0 then
		cbCardIndexTemp[GameLogic:SwitchToCardIndex(cbCurrentCard)]=cbCardIndexTemp[GameLogic:SwitchToCardIndex(cbCurrentCard)]+1
	end

	--权位处理
	if (cbCurrentCard~=0) and (cbWeaveCount==cmd.MAX_WEAVE) then
		dwChiHuRight=bit:_or(dwChiHuRight,GameLogic.CHK_QUAN_QIU_REN)
	end

	--分析扑克
	local AnalyseFallback
	local byGodsCardIndex = GameLogic:SwitchToCardIndex(GameLogic.m_byGodsCardData)
	local byBaiBan = GameLogic:SwitchToCardIndex(GameLogic.BAIBAN_CARD_DATA)
	local bIsBaDui = false
	local bIsBaDuiFallback = false
	--OUTPUT_DEBUG_STRING(TEXT("服务端财神 0x%02X"), m_byGodsCardData);
	if 1== cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser={}
		for i=1,cmd.MAX_INDEX,1 do
			cbCardIndexUser=GameLogic:deepcopy(cbCardIndexTemp)
			cbCardIndexUser[i]=cbCardIndexUser[i]+1
			cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
			AnalyseItemArrayTemp=nil
			GameLogic:AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
			GameLogic:append(AnalyseItemArray,AnalyseItemArrayTemp)
			if i == byBaiBan then
				AnalyseFallback=nil
				GameLogic:append(AnalyseFallback,AnalyseItemArrayTemp)
			end

			if (not bIsBaDui) or (not bIsBaDuiFallback) then
				if GameLogic:IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
					bIsBaDui = true
					if i == byBaiBan then
						bIsBaDuiFallback =true
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("一个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"))
	elseif 2 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=1,cmd.MAX_INDEX,1 do
			for j=1,cmd.MAX_INDEX,1 do
				cbCardIndexUser=GameLogic:deepcopy(cbCardIndexTemp)
				cbCardIndexUser[i]=cbCardIndexUser[i]+1
				cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
				cbCardIndexUser[j]=cbCardIndexUser[j]+1
				cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

				AnalyseItemArrayTemp=nil
				GameLogic:AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
				GameLogic:append(AnalyseItemArray,AnalyseItemArrayTemp)
				if (i==byBaiBan) and (j==byBaiBan) then
					AnalyseFallback=nil
					GameLogic:append(AnalyseFallback,AnalyseItemArrayTemp)
				end

				if (not bIsBaDui) or (not bIsBaDuiFallback) then
					if GameLogic:IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
						bIsBaDui = true
						if (i==byBaiBan) and (j==byBaiBan) then
							bIsBaDuiFallback =true
						end
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("两个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	elseif 3 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=1,cmd.MAX_INDEX,1 do
			for j=1,cmd.MAX_INDEX,1 do
				for h=1,cmd.MAX_INDEX,1 do
					cbCardIndexUser=GameLogic:deepcopy(cbCardIndexTemp)
					cbCardIndexUser[i]=cbCardIndexUser[i]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
					cbCardIndexUser[j]=cbCardIndexUser[j]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
					cbCardIndexUser[h]=cbCardIndexUser[h]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

					AnalyseItemArrayTemp=nil
					GameLogic:AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
					GameLogic:append(AnalyseItemArray,AnalyseItemArrayTemp)

					if (i==byBaiBan) and (j==byBaiBan) and (h==byBaiBan) then
						AnalyseFallback=nil
						GameLogic:append(AnalyseFallback,AnalyseItemArrayTemp)
					end
					if (not bIsBaDui) or (not bIsBaDuiFallback) then
						if GameLogic:IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
							bIsBaDui = true
							if (i==byBaiBan) and (j==byBaiBan) and (h==byBaiBan) then
								bIsBaDuiFallback =true
							end
						end
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("三个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	elseif 4 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=1,cmd.MAX_INDEX,1 do
			for j=1,cmd.MAX_INDEX,1 do
				for h=1,cmd.MAX_INDEX,1 do
					for m=1,cmd.MAX_INDEX,1 do
						cbCardIndexUser=GameLogic:deepcopy(cbCardIndexTemp)
						cbCardIndexUser[i]=cbCardIndexUser[i]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[j]=cbCardIndexUser[j]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[h]=cbCardIndexUser[h]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[m]=cbCardIndexUser[m]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

						AnalyseItemArrayTemp=nil
						GameLogic:AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
						GameLogic:append(AnalyseItemArray,AnalyseItemArrayTemp)

						if (i==byBaiBan)
						and (j==byBaiBan)
						and (h==byBaiBan)
						and (m==byBaiBan)
						then
							AnalyseFallback=nil
							GameLogic:append(AnalyseFallback,AnalyseItemArrayTemp)
						end
						if (not bIsBaDui) or (not bIsBaDuiFallback) then
							if GameLogic:IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
								bIsBaDui = true
								if (i==byBaiBan)
								and (j==byBaiBan)
								and (h==byBaiBan)
								and (m==byBaiBan)
								then
									bIsBaDuiFallback =true
								end
							end
						end
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("四个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	else
		GameLogic:AnalyseCard(cbCardIndexTemp,WeaveItem,cbWeaveCount,AnalyseItemArray)
		if not bIsBaDui then
			if GameLogic:IsBaDui(cbCardIndexTemp,WeaveItem,cbWeaveCount) then
				bIsBaDui = true;
			end
		end
	--OUTPUT_DEBUG_STRING(TEXT("无财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	end

	--胡牌分析
	if GameLogic:table_leng(AnalyseItemArray)>0 then
		-- 三张财神，又有其他胡牌类型
		if 0x03 == cbCardIndexTemp[byGodsCardIndex] then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_SAN_GODS)
		end

		-- 没有财神是硬牌
		if 0x00 == cbCardIndexTemp[byGodsCardIndex] then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_PAI)
		end

		-- 单张胡牌
		local byCount = 0
		for i=1,cmd.MAX_INDEX,1 do
			byCount = byCount+ cbCardIndexTemp[byGodsCardIndex]
		end
		if 0x02 == byCount then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_SINGLE_PAI)
		end

		-- 财神归位
		if GameLogic:table_leng(AnalyseFallback)>0 then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_PAI)
		end

		--牌型分析
		for i=1,GameLogic:table_leng(AnalyseItemArray),1 do
			--变量定义
			local bLianCard,bPengCard=false,false
			--tagAnalyseItem * pAnalyseItem=&AnalyseItemArray[i];
			local pAnalyseItem=AnalyseItemArray[i]

			--牌型分析
			--mark
			--for (BYTE j=0;j<CountArray(pAnalyseItem->cbWeaveKind);j++)
			for j=1,GameLogic:table_leng(pAnalyseItem[cbWeaveKind]),1 do
				local cbWeaveKind=pAnalyseItem.cbWeaveKind[j]
				bPengCard=(bit:_and(cbWeaveKind, (bit:_or(GameLogic.WIK_GANG,GameLogic.WIK_PENG)))~=0) and true or bPengCard
				bLianCard=(bit:_and(cbWeaveKind, (bit:_or(GameLogic.WIK_LEFT,(bit:_or(GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT)))))~=0) and true or bLianCard
			end
			--牌型判断

			--碰碰牌型
			if (bLianCard==false) and (bPengCard==true) then
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_PENG_PENG)
			end
			if (bLianCard==true) and (bPengCard==true) then
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_JI_HU)
			end
			if (bLianCard==true) and (bPengCard==false) then
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_PING_HU)
			end


		end

	else
		if 0x03 == cbCardIndexTemp[byGodsCardIndex] then	 -- 有三财神，没有其他胡牌
			if not bIsBaDui then
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_PAI)
			else
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_SAN_GODS)
			end
		elseif bIsBaDuiFallback then												-- 才神归位，胡八对
				dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_PAI)
		end
	end

	--牌权判断
	--if (IsQingYiSe(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuRight|=CHR_QING_YI_SE;

	--大胡牌型
	--if (IsQiXiaoDui(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuKind|=CHK_QI_XIAO_DUI;
	--if (IsShiSanYao(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuKind|=CHK_SHI_SAN_YAO;

	if bIsBaDui then
		if cbCardIndexTemp[byGodsCardIndex] > 0x00 then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_BA_DUI)
		else
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_BA_DUI)
		end
	end

	--结果判断
	if dwChiHuKind~=GameLogic.CHK_NULL then
		ChiHuResult.dwChiHuKind=bit:_or(ChiHuResult.dwChiHuKind,dwChiHuKind)
		ChiHuResult.dwChiHuRight=bit:_or(ChiHuResult.dwChiHuRight,dwChiHuRight)
		--变量定义
		if (GameLogic.CHK_YING_BA_DUI == (bit:_and(GameLogic.CHK_YING_BA_DUI, dwChiHuKind)))
				or (GameLogic.CHK_SAN_GODS == (bit:_and(GameLogic.CHK_SAN_GODS, dwChiHuKind)))
				or (GameLogic.CHK_SINGLE_PAI == (bit:_and(GameLogic.CHK_SINGLE_PAI, dwChiHuKind)))
		then
			ChiHuResult.dwWinTimes = 4
		elseif GameLogic.CHK_YING_PAI == (bit:_and(GameLogic.CHK_YING_PAI, dwChiHuKind)) then
			ChiHuResult.dwWinTimes = 2
		else
			ChiHuResult.dwWinTimes = 1
		end
		if 4 ~= ChiHuResult.dwWinTimes then
			if GameLogic.CHR_DI == (bit:_and(dwChiHuRight, GameLogic.CHR_DI)) then
				ChiHuResult.dwWinTimes = 4
			end
			if GameLogic.CHR_TIAN == (bit:_and(dwChiHuRight, GameLogic.CHR_TIAN)) then
				ChiHuResult.dwWinTimes = 4
			end
		end
		return GameLogic.WIK_CHI_HU
	end
	return GameLogic.WIK_NULL
end

--十三夭牌
function GameLogic:IsShiSanYao(cbCardIndex,WeaveItem,cbWeaveCount)
		--组合判断
		if cbWeaveCount~=0 then		return false	end

		--扑克判断
		local bCardEye=false

		--一九判断
		for i=1,27,9 do
			--无效判断
			if cbCardIndex[i]==0 then return false end
			if cbCardIndex[i+8]==0 then return false end

			--牌眼判断
			if (bCardEye==false) and (cbCardIndex[i]==2) then bCardEye=true end
			if (bCardEye==false) and (cbCardIndex[i+8]==2) then bCardEye=true end
		end

		--番子判断
		for i=27,cmd.MAX_INDEX-1,1 do
			if cbCardIndex[i]==0 then return false	end
			if (bCardEye==false) and (cbCardIndex[i]==2) then bCardEye=true	end
		end

		--牌眼判断
		if bCardEye==false then return false end

		return true
end

--清一色牌
function GameLogic:IsQingYiSe(cbCardIndex,WeaveItem,cbItemCount)
	local cbCardColor= 0xFF
	for i=1,cmd.MAX_INDEX,1 do
		if cbCardIndex[i]~=0 then
			--花色判断
			if cbCardColor~= 0xFF then
				return false
			end

			--设置花色
			cbCardColor=(bit:_and(GameLogic:SwitchToCardData(i), GameLogic.MASK_COLOR))

			--设置索引
			i=(i/9+1)*9-1
		end
	end

	--组合判断
	for i=1,cbItemCount,1 do
		local cbCenterCard=WeaveItem[i].cbCenterCard
		if bit:_and(cbCenterCard, GameLogic.MASK_COLOR)~=cbCardColor then
			return false
		end
	end
	return true
end

--七小对牌
function GameLogic:IsQiXiaoDui(cbCardIndex,WeaveItem,cbWeaveCount)
	--组合判断
	if cbWeaveCount~=0 then
		return false
	end

	--扑克判断
	for i=1,cmd.MAX_INDEX,1 do
		local cbCardCount=cbCardIndex[i]
		if (cbCardCount~=0) and (cbCardCount~=2) and (cbCardCount~=4) then
			return false
		end
	end

	return true
end

--八对
function GameLogic:IsBaDui(cbCardIndex,WeaveItem,cbWeaveCount)
	--组合判断
	if cbWeaveCount~=0 then
		return false
	end

	--扑克判断
	local iCount = 0
	for i=1,cmd.MAX_INDEX,1 do
		local cbCardCount=cbCardIndex[i]
		if 0x00 ~= (cbCardCount%2) then
			iCount=iCount+1
			if iCount>1 then
				return false
			end
		end
	end
	return true

end

--扑克转换
function GameLogic:SwitchToCardData(...)
	local arg={...}
	local len=#arg
	if len==1 then	return GameLogic:SwitchToCardData_1(arg[1])
	elseif len==2 then	return GameLogic:SwitchToCardData_2(arg[1],arg[2])
	else	print("SwitchToCardData 参数个数不符合")
	end
end
--BYTE CGameLogic::SwitchToCardData(BYTE cbCardIndex)
function GameLogic:SwitchToCardData_1(cbCardIndex)
	if GameLogic.m_byGodsCardData>0 then
			if GameLogic:SwitchToCardIndex(GameLogic.BAIBAN_CARD_DATA) == cbCardIndex then
				return GameLogic.BAIBAN_CARD_DATA
			elseif GameLogic:SwitchToCardIndex(GameLogic.m_byGodsCardData) == cbCardIndex then
				return GameLogic.m_byGodsCardData
			else
				return bit:_or((bit:_lshift(cbCardIndex/9, 4)),(cbCardIndex%9+1))
			end
	end

	return bit:_or((bit:_lshift(cbCardIndex/9, 4)),(cbCardIndex%9+1))
end

--扑克转换
function GameLogic:SwitchToCardIndex(...)
	local arg={...}
	local len=#arg
	if len==1 then	return GameLogic:SwitchToCardIndex_1(arg[1])
	elseif len==3 then return GameLogic:SwitchToCardIndex_3(arg[1],arg[2],arg[3])
	else	print("SwitchToCardIndex 参数个数不符合 len",len)
	end
end
--BYTE CGameLogic::SwitchToCardIndex(BYTE cbCardData)
function GameLogic:SwitchToCardIndex_1(cbCardData)
	if GameLogic.m_byGodsCardData>0 then
		if GameLogic.BAIBAN_CARD_DATA ==cbCardData then			 -- 将白板跟财神交换
			cbCardData = GameLogic.m_byGodsCardData
		elseif GameLogic.m_byGodsCardData ==cbCardData then
			cbCardData = GameLogic.BAIBAN_CARD_DATA
		end
	end
	local tem_val1=bit:_and(cbCardData, GameLogic.MASK_COLOR)
	local tem_val2=(bit:_rshift(tem_val1, 4))*9
	local tem_val3=bit:_and(cbCardData, GameLogic.MASK_VALUE)-1
--print(tem_val1,tem_val2,tem_val3,tem_val2+tem_val3)
	return tem_val2+tem_val3 
end

--扑克转换
--BYTE CGameLogic::SwitchToCardData(BYTE cbCardIndex[MAX_INDEX], BYTE cbCardData[MAX_COUNT])
function GameLogic:SwitchToCardData_2(cbCardIndex,cbCardData)
	local cbPosition=0
	local byIndex = 0xFF
	--转换扑克
	if GameLogic.m_byGodsCardData>0 then
		-- 财神放在第一位
		byIndex = GameLogic:SwitchToCardIndex(GameLogic.m_byGodsCardData)
		if 0 ~= cbCardIndex[byIndex] then -- 首先把财神 加入
			for j=1,cbCardIndex[byIndex]+1,1 do
				cbPosition=cbPosition+1
				cbCardData[cbPosition]=GameLogic:SwitchToCardData(byIndex)
			end
		end
	end
	for i=1,cmd.MAX_INDEX,1 do
		while true do

				if byIndex == i then break	end

				if cbCardIndex[i]~=0 then
					for j=1,cbCardIndex[i],1 do
						cbPosition=cbPosition+1
						cbCardData[cbPosition]=GameLogic:SwitchToCardData(i)
					end
				end

		break	end
	end

	return cbPosition
end

function GameLogic:SetGodsCard(byCardData)
	GameLogic.m_byGodsCardData=byCardData
end

--扑克转换
--BYTE CGameLogic::SwitchToCardIndex(BYTE cbCardData[], BYTE cbCardCount, BYTE cbCardIndex[MAX_INDEX])
function GameLogic:SwitchToCardIndex_3(cbCardData,cbCardCount,cbCardIndex)
	--设置变量
	--cbCardIndex={}
  	cbCardIndex=GameLogic:sizeM(GameLogic:table_leng(cbCardIndex))

	--转换扑克
	for i=1,cbCardCount,1 do
		local tem_i =GameLogic:SwitchToCardIndex(cbCardData[i])
        --print(tem_i)
		cbCardIndex[tem_i+1]=cbCardIndex[tem_i+1]+1
	end

	--mark  cbCardIndex 未传回 估计用的是SwitchToCardIndex_1
	return cbCardCount
end

--分析扑克
function GameLogic:AnalyseCard(cbCardIndex,WeaveItem,cbWeaveCount,AnalyseItemArray)
	--计算数目
	local cbCardCount=0
	for i=1,cmd.MAX_INDEX,1 do
		cbCardCount=cbCardCount+cbCardIndex[i]
	end

	--效验数目
	if (cbCardCount<2) or (cbCardCount>cmd.MAX_COUNT) or ((cbCardCount-2)%3~=0) then	return false	end

	--变量定义
	local cbKindItemCount=0
	--tagKindItem KindItem[MAX_COUNT-2];
	--ZeroMemory(KindItem,sizeof(KindItem));
	local KindItem

	--需求判断
	local cbLessKindItem=(cbCardCount-2)/3;

	local byGodsIndex = GameLogic:SwitchToCardIndex(GameLogic.m_byGodsCardData)
	--单吊判断
	if cbLessKindItem==0 then
		--效验参数
		--ASSERT((cbCardCount==2)&&(cbWeaveCount==MAX_WEAVE));

		--牌眼判断
		for i=1,cmd.MAX_INDEX,1 do
			if (cbCardIndex[i]==2)
			or ((cbCardIndex[i]==1)
			and (i ~= byGodsIndex)
			and (cbCardIndex[byGodsIndex]>0))
			then
				--变量定义
				--tagAnalyseItem AnalyseItem;
				--ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));
				--local AnalyseItem=nil
				local AnalyseItem={}

				--设置结果
				for j=1,cbWeaveCount,1 do
					AnalyseItem.cbWeaveKind[j]=WeaveItem[j].cbWeaveKind
					AnalyseItem.cbCenterCard[j]=WeaveItem[j].cbCenterCard
				end
				AnalyseItem.cbCardEye=GameLogic:SwitchToCardData(i)

				--插入结果
				GameLogic:add(AnalyseItemArray,AnalyseItem)

				return true
			end
		end

		return false
	end

	-- 拆分分析
	if cbCardCount>=3 then
		for i=1,cmd.MAX_INDEX,1 do
		--同牌判断
			if cbCardIndex[i]>=3 then
				KindItem[cbKindItemCount].cbCardIndex[1]=i
				KindItem[cbKindItemCount].cbCardIndex[2]=i
				KindItem[cbKindItemCount].cbCardIndex[3]=i
				KindItem[cbKindItemCount].cbWeaveKind=GameLogic.WIK_PENG
				cbKindItemCount=cbKindItemCount+1
				KindItem[cbKindItemCount].cbCenterCard=GameLogic:SwitchToCardData(i)
			end
			-- 连牌判断
			if (i<(cmd.MAX_INDEX-9)) and (cbCardIndex[i]>0) and ((i%9)<7) then
				for j=1,cbCardIndex[i],1 do
					if (cbCardIndex[i+1]>=j) and (cbCardIndex[i+2]>=j) then
						KindItem[cbKindItemCount].cbCardIndex[1]=i
						KindItem[cbKindItemCount].cbCardIndex[2]=i+1
						KindItem[cbKindItemCount].cbCardIndex[3]=i+2
						KindItem[cbKindItemCount].cbWeaveKind=GameLogic.WIK_LEFT
						cbKindItemCount=cbKindItemCount+1
						KindItem[cbKindItemCount].cbCenterCard=GameLogic:SwitchToCardData(i)
					end
				end
			end
		end
	end

	--组合分析
	if cbKindItemCount>=cbLessKindItem then
		--变量定义
		--local cbCardIndexTemp=nil
		local cbCardIndexTemp={}
		--ZeroMemory(cbCardIndexTemp,sizeof(cbCardIndexTemp));

		--变量定义
		local cbIndex={0,1,2,3,4}
		--tagKindItem * pKindItem[MAX_WEAVE];
		--ZeroMemory(&pKindItem,sizeof(pKindItem));
		--local pKindItem=nil
		local pKindItem={}

		--开始组合 do while
		local notFirstLoop =0
		while true do
			notFirstLoop=notFirstLoop+1
			--设置变量
			cbCardIndexTemp=GameLogic:deepcopy(cbCardIndex)
			for i=1,cbLessKindItem,1 do
				pKindItem[i]=KindItem[cbIndex[i]]
			end

			--数量判断
			local bEnoughCard=true
			while true do
				for i=1,cbLessKindItem*3-1,1 do
					--存在判断
					local cbCardIndex=pKindItem[i/3].cbCardIndex[i%3]
					if cbCardIndexTemp[cbCardIndex]==0 then
						bEnoughCard=false
						if notFirstLoop~=1 then
							break
						end
					else
						cbCardIndexTemp[cbCardIndex]=cbCardIndexTemp[cbCardIndex]-1
					end
				end
			end

			--胡牌判断
			if bEnoughCard==true then
				--牌眼判断
				local cbCardEye=0
				while true do
					for i=1,cmd.MAX_INDEX,1 do
						if cbCardIndexTemp[i]==2 then
							cbCardEye=GameLogic:SwitchToCardData(i)
							if notFirstLoop~=1 then
								break
							end
						end
					end
				end

				--组合类型
				if cbCardEye~=0 then
					--变量定义
					--local AnalyseItem=nil
					local AnalyseItem={}
					--tagAnalyseItem AnalyseItem;
					--ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));

					--设置组合
					for i=1,cbWeaveCount-1,1 do
						AnalyseItem.cbWeaveKind[i]=WeaveItem[i].cbWeaveKind
						AnalyseItem.cbCenterCard[i]=WeaveItem[i].cbCenterCard
					end

					--设置牌型
					for i=1,cbLessKindItem,1 do
						AnalyseItem.cbWeaveKind[i+cbWeaveCount]=pKindItem[i].cbWeaveKind
						AnalyseItem.cbCenterCard[i+cbWeaveCount]=pKindItem[i].cbCenterCard
					end

					--设置牌眼
					AnalyseItem.cbCardEye=cbCardEye

					--插入结果
					GameLogic:add(AnalyseItemArray,AnalyseItem)

				end
			end

			--设置索引
			if cbIndex[cbLessKindItem-1]==(cbKindItemCount-1) then
				while true do
					for i=cbLessKindItem-1,0+1,-1 do
						if (cbIndex[i-1]+1)~=cbIndex[i] then
							local cbNewIndex=cbIndex[i-1]
							for j=(i-1),cbLessKindItem-1,1 do
								cbIndex[j]=cbNewIndex+j-i+2
							end
							if notFirstLoop~=1 then
								break
							end
						end
					end
				end
				if i==0 then			--i 有定义么？ mark
					if notFirstLoop~=1 then
						break
					end
				end
			else
				cbIndex[cbLessKindItem-1]=cbIndex[cbLessKindItem-1]+1
			end
		end
		--while (true);
	end

	return (GameLogic:table_leng(AnalyseItemArray)>0)
end

return GameLogic

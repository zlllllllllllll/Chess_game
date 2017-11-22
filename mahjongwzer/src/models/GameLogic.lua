local GameLogic = {}

local ExternalFun =  appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
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
GameLogic.WIK_CENTER		=			0x02								--中吃类型
GameLogic.WIK_RIGHT			=		0x04								--右吃类型
GameLogic.WIK_PENG			=		0x08								--碰牌类型
GameLogic.WIK_GANG			=		0x10								--杠牌类型
GameLogic.WIK_LISTEN		=			0x20								--听牌类型
GameLogic.WIK_CHI_HU		=			0x40								--吃胡类型

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
GameLogic.tagKindItem
{
	{k = "cbWeaveKind", t = "byte"},					--组合类型
	{k = "cbCenterCard", t = "byte"},					--中心扑克
	{k = "cbCardIndex", t = "byte",l = {3}} 	--扑克索引
};

--组合子项
GameLogic.tagWeaveItem
{
	{k = "cbWeaveKind", t = "byte"},					--组合类型
	{k = "cbCenterCard", t = "byte"},					--中心扑克
	{k = "cbPublicCard", t = "byte"},					--公开标志
	{k = "wProvideUser", t = "word"}					--供应用户
};

--胡牌结果
GameLogic.tagChiHuResult
{
	{k = "dwChiHuKind", t = "dword"},					--吃胡类型
	{k = "dwChiHuRight", t = "dword"},				--胡牌权位
	{k = "dwWinTimes", t = "dword"}						--番数数目
};

--杠牌结果
GameLogic.tagGangCardResult
{
	{k = "cbCardCount", t = "byte"},					--扑克数目
	{k = "cbCardData", t = "byte",l = {4}},		--扑克数据
	{k = "cbGangType", t = "byte"}						--杠牌类型
};

--分析子项
GameLogic.tagAnalyseItem
{
	{k = "cbCardEye", t = "byte"},						--牌眼扑克
	{k = "cbWeaveKind", t = "byte",l = {cmd.MAX_WEAVE}},			--组合类型
	{k = "cbCenterCard", t = "byte" ,l = {cmd.MAX_WEAVE}},		--中心扑克
};

GameLogic.BAIBAN_CARD_DATA  = 0x37   -- 白板

GameLogic.m_byGodsCardData   -- 财神
--------------------------------------------------------------------------

--数组说明
--typedef CWHArray<tagAnalyseItem,tagAnalyseItem &> CAnalyseItemArray;

--游戏逻辑类
class CGameLogic
{
	--变量定义
protected:
	--static const BYTE				m_cbCardDataArray[MAX_REPERTORY];	--扑克数据
	BYTE m_byGodsCardData;          -- 财神

	--函数定义
public:
	--构造函数
	CGameLogic();
	--析构函数
	virtual ~CGameLogic();

	--控制函数
public:
	--混乱扑克
	--删除扑克
	bool RemoveCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard);
	--删除扑克
	bool RemoveCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard[], BYTE cbRemoveCount);
	--删除扑克
	bool RemoveCard(BYTE cbCardData[], BYTE cbCardCount, BYTE cbRemoveCard[], BYTE cbRemoveCount);
	--辅助函数
	--有效判断
	bool IsValidCard(BYTE cbCardData);
	--扑克数目
	BYTE GetCardCount(BYTE cbCardIndex[MAX_INDEX]);
	--组合扑克
	BYTE GetWeaveCard(BYTE cbWeaveKind, BYTE cbCenterCard, BYTE cbCardBuffer[4]);
	--等级函数
	--动作等级
	BYTE GetUserActionRank(BYTE cbUserAction);
	--胡牌等级
	WORD GetChiHuActionRank(tagChiHuResult & ChiHuResult);
	--动作判断
	--吃牌判断
	BYTE EstimateEatCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbCurrentCard);
	--碰牌判断
	BYTE EstimatePengCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbCurrentCard);
	--杠牌判断
	BYTE EstimateGangCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbCurrentCard);
	--动作判断
	--听牌分析
	BYTE AnalyseTingCard(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount, DWORD dwChiHuRight);
	--杠牌分析
	BYTE AnalyseGangCard(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount, tagGangCardResult & GangCardResult);
	--吃胡分析
	BYTE AnalyseChiHuCard(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount, BYTE cbCurrentCard, DWORD dwChiHuRight, tagChiHuResult & ChiHuResult);
	--特殊胡牌
	--清一色牌
	bool IsQingYiSe(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount);
	--七小对牌
	bool IsQiXiaoDui(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount);
	--十三夭牌
	bool IsShiSanYao(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount);
	-- 八对
	bool IsBaDui(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount);
	--转换函数
	--扑克转换
	BYTE SwitchToCardData(BYTE cbCardIndex);
	--扑克转换
	BYTE SwitchToCardIndex(BYTE cbCardData);
	--扑克转换
	BYTE SwitchToCardData(BYTE cbCardIndex[MAX_INDEX], BYTE cbCardData[MAX_COUNT]);
	--扑克转换
	BYTE SwitchToCardIndex(BYTE cbCardData[], BYTE cbCardCount, BYTE cbCardIndex[MAX_INDEX]);
	void SetGodsCard(BYTE byCardData);
	--内部函数
private:
	--分析扑克
	bool AnalyseCard(BYTE cbCardIndexUser[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount, CAnalyseItemArray & AnalyseItemArray);
};

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
};

--拷贝数组
function GameLogic.deepcopy(object)
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

--混乱扑克
function GameLogic.RandCardData(cbCardData,cbMaxCount,userid)	--这个里面的随机要加二个用户的userid之合，不然会牌一样的
	--混乱准备
	local cbCardDataTemp=GameLogic.deepcopy(GameLogic.m_cbCardDataArray)

	--初始化种子   客户端不需要？
	--math.randomseed(os.time()+userid)

	--混乱扑克
	local cbRandCount,cbPosition=0,0
	cbPosition=math.random()%(cbMaxCount-cbRandCount)
	cbCardData[cbRandCount+1]=cbCardDataTemp[cbPosition]
	cbCardDataTemp[cbPosition]=cbCardDataTemp[cbMaxCount-cbRandCount]
	while(cbRandCount<cbMaxCount)
	do
			cbPosition=math.random()%(cbMaxCount-cbRandCount)
			cbCardData[cbRandCount+1]=cbCardDataTemp[cbPosition]
			cbCardDataTemp[cbPosition]=cbCardDataTemp[cbMaxCount-cbRandCount]
	end

	return
end

--删除扑克
--CGameLogic::RemoveCard(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard)
--											(BYTE cbCardIndex[MAX_INDEX], BYTE cbRemoveCard[], BYTE cbRemoveCount)
--											(BYTE cbCardData[], BYTE cbCardCount, BYTE cbRemoveCard[], BYTE cbRemoveCount)
--====   RemoveCard1
function GameLogic.RemoveCard1(cbCardIndex,cbRemoveCard)
	--效验扑克
	-- ASSERT(IsValidCard(cbRemoveCard));
	-- ASSERT(cbCardIndex[SwitchToCardIndex(cbRemoveCard)]>0);
	--删除扑克
	local cbRemoveIndex=GameLogic.SwitchToCardIndex(cbRemoveCard)
	if cbCardIndex[cbRemoveIndex]>0 then
		cbCardIndex[cbRemoveIndex]=cbCardIndex[cbRemoveIndex]-1
		return true
	end
	return false
end

--====   RemoveCard2
function GameLogic.RemoveCard2(cbCardIndex,cbRemoveCard,cbRemoveCount)
	--删除扑克
	for i=0,cbRemoveCount-1,1 do
		--效验扑克
		--ASSERT(IsValidCard(cbRemoveCard[i]));
		--ASSERT(cbCardIndex[SwitchToCardIndex(cbRemoveCard[i])]>0);

		--删除扑克
		local cbRemoveIndex=GameLogic.SwitchToCardIndex(cbRemoveCard[i])
		--变相continue
  	while true do
			if cbCardIndex[cbRemoveIndex]==0 then

				--还原删除
				for j=0,i-1,1 do
					--ASSERT(IsValidCard(cbRemoveCard[j]))
					cbCardIndex[GameLogic.SwitchToCardIndex(cbRemoveCard[j])]=cbCardIndex[GameLogic.SwitchToCardIndex(cbRemoveCard[j])]+1
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

--====   RemoveCard3
function GameLogic.RemoveCard3(cbCardData,cbCardCount,cbRemoveCard,cbRemoveCount)
	--检验数据
	-- ASSERT(cbCardCount<=MAX_COUNT);
	-- ASSERT(cbRemoveCount<=cbCardCount);

	--定义变量
	local cbDeleteCount=0,cbTempCardData={};
	if cbCardCount>cmd.MAX_COUNT then
		return false
	end
	--问题mark 不确定
	--CopyMemory(cbTempCardData,cbCardData,cbCardCount*sizeof(cbCardData[0]));
	local cbTempCardData=GameLogic.deepcopy(cbCardData)

	--置零扑克
	for i=0,cbRemoveCount-1,1 do
		while true do
			for j=0,cbCardCount-1,1 do
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
	for i=0,cbCardCount-1,1 do
		if cbTempCardData[i]~=0 then
			cbCardData[cbCardPos+1]=cbTempCardData[i];
		end
	end

	return true
end

--有效判断
function GameLogic.IsValidCard(cbCardData)
	local cbValue = bit:_and(cbCardData, MASK_VALUE)
	local cbColor = bit:_rshift(bit:_and(cbCardData, MASK_COLOR),4)
	return (((cbValue>=1)and(cbValue<=9)and(cbColor<=2))or((cbValue>=1)and(cbValue<=7)and(cbColor==3)))
end

--扑克数目
function GameLogic.GetCardCount(cbCardIndex)
	local cbCardCount = 0
	for i=0,cmd.MAX_COUNT-1,1 do
		cbCardCount=cbCardCount+cbCardIndex[i]
	end
	return cbCardCount;
end

--获取组合
function GameLogic.GetWeaveCard(cbWeaveKind,cbCenterCard,cbCardBuffer)
	--组合扑克
	local switch = {
	    [GameLogic.WIK_LEFT] = function()    -- 上牌操作
					--设置变量
					if GameLogic.BAIBAN_CARD_DATA == cbCenterCard then
						cbCenterCard = GameLogic.m_byGodsCardData
					end
					cbCardBuffer[0]=cbCenterCard
					cbCardBuffer[1]=cbCenterCard+1
					cbCardBuffer[2]=cbCenterCard+2
					for i=0, i<3-1, 1 do
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
					cbCardBuffer[0]=cbCenterCard-2
					cbCardBuffer[1]=cbCenterCard-1
					cbCardBuffer[2]=cbCenterCard
					for i=0, i<3-1, 1 do
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
					cbCardBuffer[0]=cbCenterCard-1
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard+1
					for i=0, i<3-1, 1 do
						if GameLogic.m_byGodsCardData == cbCardBuffer[i] then
							cbCardBuffer[i]=GameLogic.BAIBAN_CARD_DATA
						end
					end
					return 3
	    end,
	    [GameLogic.WIK_PENG] = function()    --碰牌操作
					--设置变量
					cbCardBuffer[0]=cbCenterCard
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard

					return 3
	    end,
	    [GameLogic.WIK_GANG] = function()    --杠牌操作
					--设置变量
					cbCardBuffer[0]=cbCenterCard
					cbCardBuffer[1]=cbCenterCard
					cbCardBuffer[2]=cbCenterCard
					cbCardBuffer[3]=cbCenterCard

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
function GameLogic.GetUserActionRank(cbUserAction)
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
function GameLogic.GetChiHuActionRank(ChiHuResult)
	return 0
end

--吃牌判断
function GameLogic.EstimateEatCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard))

		-- 财神不可以吃
		if cbCurrentCard == GameLogic.m_byGodsCardData
			return GameLogic.WIK_NULL
		end

		--过滤判断
		--番子无连
		if (cbCurrentCard>= 0x31) and (GameLogic.BAIBAN_CARD_DATA ~= cbCurrentCard) then
			return GameLogic.WIK_NULL
		end
		if (cbCurrentCard>= 0x31) and ((GameLogic.BAIBAN_CARD_DATA == cbCurrentCard) and (GameLogic.m_byGodsCardData>= 0x31))
			return GameLogic.WIK_NULL
		end

		--变量定义
		local cbExcursion={0,1,2}
		local cbItemKind={GameLogic.WIK_LEFT,GameLogic.WIK_CENTER,GameLogic.WIK_RIGHT}

		--吃牌判断
		local cbEatKind,cbFirstIndex=0,0
		local cbCurrentIndex=GameLogic.SwitchToCardIndex(cbCurrentCard)
		if (cbCurrentIndex > 27)
		{
			return GameLogic.WIK_NULL
		}

		for i=0,#cbItemKind-1,1 do
				local cbValueIndex=cbCurrentIndex%9
				while (cbValueIndex>=cbExcursion[i]) and ((cbValueIndex-cbExcursion[i])<=6) do
						--吃牌判断
						cbFirstIndex=cbCurrentIndex-cbExcursion[i]
						if (cbCurrentIndex~=cbFirstIndex) and (cbCardIndex[cbFirstIndex]==0) break	end

						if (cbCurrentIndex~=(cbFirstIndex+1)) and (cbCardIndex[cbFirstIndex+1]==0) break	end

						if (cbCurrentIndex~=(cbFirstIndex+2)) and (cbCardIndex[cbFirstIndex+2]==0) break	end

						--设置类型
						cbEatKind=bit:_or(cbEatKind,cbItemKind[i])
				break	end
		end

		return cbEatKind
end

--碰牌判断
function GameLogic.EstimatePengCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard))

	--碰牌判断
	return (cbCardIndex[GameLogic.SwitchToCardIndex(cbCurrentCard)]>=2) and GameLogic.WIK_PENG or GameLogic.WIK_NULL
end

--杠牌判断
function GameLogic.EstimateGangCard(cbCardIndex,cbCurrentCard)
	--参数效验
	--ASSERT(IsValidCard(cbCurrentCard));

	--杠牌判断
	return (cbCardIndex[GameLogic.SwitchToCardIndex(cbCurrentCard)]==3) and GameLogic.WIK_GANG or GameLogic.WIK_NULL
end

--听牌分析
function GameLogic.AnalyseTingCard(cbCardIndex, WeaveItem,cbItemCount,dwChiHuRight)
{
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
}

--杠牌分析    GameLogic.tagWeaveItem WeaveItem   --   GameLogic.tagGangCardResult GangCardResult
function GameLogic.AnalyseGangCard(cbCardIndex,WeaveItem,cbWeaveCount,GangCardResult)
	--设置变量
	local cbActionMask= GameLogic.WIK_NULL
	--问题mark 不确定 GangCardResult结构体 暂为写到调用改方法 临时跳过   下同 LSTG   确保 GangCardResult有效？
	--ZeroMemory(&GangCardResult,sizeof(GangCardResult))
	GangCardResult=nil

	--手上杠牌
	for i=0,cmd.MAX_INDEX-1,1 do
		if cbCardIndex[i]==4 then
			cbActionMask=bit:_or(cbActionMask,GameLogic.WIK_GANG)

			--LSTG
			--GangCardResult.cbCardData[GangCardResult.cbCardCount]=WIK_GANG
			--GangCardResult.cbCardData[GangCardResult.cbCardCount++]=SwitchToCardData(i)
		end
	end

	--组合杠牌
	for i=0,cbWeaveCount-1,1 do
		if WeaveItem[i].cbWeaveKind==GameLogic.WIK_PENG then
			if cbCardIndex[GameLogic.SwitchToCardIndex(WeaveItem[i].cbCenterCard)]==1 then
				cbActionMask=bit:_or(cbActionMask,GameLogic.WIK_GANG)

				--LSTG
				--GangCardResult.cbCardData[GangCardResult.cbCardCount]=WIK_GANG;
				--GangCardResult.cbCardData[GangCardResult.cbCardCount++]=WeaveItem[i].cbCenterCard;
			end
		end
	end

	return cbActionMask
end

--吃胡分析
function GameLogic.AnalyseChiHuCard(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard,dwChiHuRight,tagChiHuResult,ChiHuResult)
	--变量定义
	local dwChiHuKind=GameLogic.CHK_NULL
	local AnalyseItemArray

	--设置变量
	--ZeroMemory(&ChiHuResult,sizeof(ChiHuResult))
	ChiHuResult=nil					--待确认是否合理

	--构造扑克
	local cbCardIndexTemp=GameLogic.deepcopy(cbCardIndex)

	--插入扑克
	if cbCurrentCard~=0 then
		cbCardIndexTemp[GameLogic.SwitchToCardIndex(cbCurrentCard)]=cbCardIndexTemp[GameLogic.SwitchToCardIndex(cbCurrentCard)]+1
	end

	--权位处理
	if (cbCurrentCard~=0) and (cbWeaveCount==cmd.MAX_WEAVE) then
		dwChiHuRight=bit:_or(dwChiHuRight,GameLogic.CHK_QUAN_QIU_REN)
	end

	--分析扑克
	local AnalyseFallback
	local byGodsCardIndex = GameLogic.SwitchToCardIndex(GameLogic.m_byGodsCardData)
	local byBaiBan = GameLogic.SwitchToCardIndex(GameLogic.BAIBAN_CARD_DATA)
	local bIsBaDui = false
	local bIsBaDuiFallback = false
	--OUTPUT_DEBUG_STRING(TEXT("服务端财神 0x%02X"), m_byGodsCardData);
	if 1== cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser[cmd.MAX_INDEX]
		for i=0,cmd.MAX_INDEX-1,1 do
			cbCardIndexUser=GameLogic.deepcopy(cbCardIndexTemp)
			cbCardIndexUser[i]=cbCardIndexUser[i]+1
			cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
			--AnalyseItemArrayTemp.RemoveAll();
			AnalyseItemArrayTemp=nil
			GameLogic.AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
			--mark
			AnalyseItemArray.Append(AnalyseItemArrayTemp)
			if i == byBaiBan then
				--mark
				--AnalyseFallback.RemoveAll()
				AnalyseFallback=nil
				AnalyseFallback.Append(AnalyseItemArrayTemp)
			end

			if (not bIsBaDui) or (not bIsBaDuiFallback) then
				if GameLogic.IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
					bIsBaDui = true
					if i == byBaiBan then
						bIsBaDuiFallback =true
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("一个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"))
	end
	elseif 2 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=0,cmd.MAX_INDEX-1,1 do
			for j=0,cmd.MAX_INDEX-1,1 do
				cbCardIndexUser=GameLogic.deepcopy(cbCardIndexTemp)
				cbCardIndexUser[i]=cbCardIndexUser[i]+1
				cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
				cbCardIndexUser[j]=cbCardIndexUser[j]+1
				cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

				--mark
				--AnalyseItemArrayTemp.RemoveAll();
				AnalyseItemArrayTemp=nil
				GameLogic.AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
				AnalyseItemArray.Append(AnalyseItemArrayTemp)
				if (i==byBaiBan) and (j==byBaiBan) then
					--mark
					--AnalyseFallback.RemoveAll();
					AnalyseFallback=nil
					AnalyseFallback.Append(AnalyseItemArrayTemp);
				end

				if (not bIsBaDui) or (not bIsBaDuiFallback) then
					if GameLogic.IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
						bIsBaDui = true
						if (i==byBaiBan) and (j==byBaiBan) then
							bIsBaDuiFallback =true
						end
					end
				end
			end
		end
		--OUTPUT_DEBUG_STRING(TEXT("两个财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	end
	elseif 3 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=0,cmd.MAX_INDEX-1,1 do
			for j=0,cmd.MAX_INDEX-1,1 do
				for h=0,cmd.MAX_INDEX-1,1 do
					cbCardIndexUser=GameLogic.deepcopy(cbCardIndexTemp)
					cbCardIndexUser[i]=cbCardIndexUser[i]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
					cbCardIndexUser[j]=cbCardIndexUser[j]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
					cbCardIndexUser[h]=cbCardIndexUser[h]+1
					cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

					--mark
					--AnalyseItemArrayTemp.RemoveAll();
					AnalyseItemArrayTemp=nil
					GameLogic.AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
					AnalyseItemArray.Append(AnalyseItemArrayTemp)

					if (i==byBaiBan) and (j==byBaiBan) and (h==byBaiBan) then
						--mark
						--AnalyseFallback.RemoveAll();
						AnalyseFallback=nil
						AnalyseFallback.Append(AnalyseItemArrayTemp)
					end
					if (not bIsBaDui) or (not bIsBaDuiFallback) then
						if GameLogic.IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
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
	end
	elseif 4 == cbCardIndexTemp[byGodsCardIndex] then
		local AnalyseItemArrayTemp
		local cbCardIndexUser
		for i=0,cmd.MAX_INDEX-1,1 do
			for j=0,cmd.MAX_INDEX-1,1 do
				for h=0,cmd.MAX_INDEX-1,1 do
					for m=0,cmd.MAX_INDEX-1,1 do
						cbCardIndexUser=GameLogic.deepcopy(cbCardIndexTemp)
						cbCardIndexUser[i]=cbCardIndexUser[i]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[j]=cbCardIndexUser[j]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[h]=cbCardIndexUser[h]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1
						cbCardIndexUser[m]=cbCardIndexUser[m]+1
						cbCardIndexUser[byGodsCardIndex]=cbCardIndexUser[byGodsCardIndex]-1

						--mark
						--AnalyseItemArrayTemp.RemoveAll();
						AnalyseItemArrayTemp=nil
						GameLogic.AnalyseCard(cbCardIndexUser,WeaveItem,cbWeaveCount,AnalyseItemArrayTemp)
						AnalyseItemArray.Append(AnalyseItemArrayTemp)

						if (i==byBaiBan)
						and (j==byBaiBan)
						and (h==byBaiBan)
						and (m==byBaiBan)
						then
							--mark
							--AnalyseFallback.RemoveAll();
							AnalyseFallback=nil
							AnalyseFallback.Append(AnalyseItemArrayTemp)
						end
						if (not bIsBaDui) or (not bIsBaDuiFallback) then
							if GameLogic.IsBaDui(cbCardIndexUser,WeaveItem,cbWeaveCount) then
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
	end
	else
		GameLogic.AnalyseCard(cbCardIndexTemp,WeaveItem,cbWeaveCount,AnalyseItemArray)
		if not bIsBaDui then
			if GameLogic.IsBaDui(cbCardIndexTemp,WeaveItem,cbWeaveCount) then
				bIsBaDui = true;
			end
		end
	--OUTPUT_DEBUG_STRING(TEXT("无财神时 %s可以胡牌"), AnalyseItemArray.GetCount()>0?TEXT(""):TEXT("不"));
	end

	--胡牌分析
	if #AnalyseItemArray>0 then
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
		for i=0,cmd.MAX_INDEX-1,1 do
			byCount += cbCardIndexTemp[byGodsCardIndex]
		end
		if 0x02 == byCount then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_SINGLE_PAI)
		end

		-- 财神归位
		if #AnalyseFallback>0 then
			dwChiHuKind=bit:_or(dwChiHuKind,GameLogic.CHK_YING_PAI)
		end

		--牌型分析
		for i=0,#AnalyseItemArray-1,1 do
			--变量定义
			local bLianCard,bPengCard=false,false
			--tagAnalyseItem * pAnalyseItem=&AnalyseItemArray[i];
			local pAnalyseItem=AnalyseItemArray[i]

			--牌型分析
			--mark
			--for (BYTE j=0;j<CountArray(pAnalyseItem->cbWeaveKind);j++)
			for i=0,#pAnalyseItem[cbWeaveKind],1 do
				local cbWeaveKind=pAnalyseItem->cbWeaveKind[j];
				bPengCard=((cbWeaveKind&(WIK_GANG|WIK_PENG))!=0)?true:bPengCard;
				bLianCard=((cbWeaveKind&(WIK_LEFT|WIK_CENTER|WIK_RIGHT))!=0)?true:bLianCard;
			end
		end

	end

end
----------

		--胡牌分析
		{
			{
				--牌型分析
				{
					BYTE cbWeaveKind=pAnalyseItem->cbWeaveKind[j];
					bPengCard=((cbWeaveKind&(WIK_GANG|WIK_PENG))!=0)?true:bPengCard;
					bLianCard=((cbWeaveKind&(WIK_LEFT|WIK_CENTER|WIK_RIGHT))!=0)?true:bLianCard;
				}

				--牌型判断
				ASSERT((bLianCard==true)||(bPengCard==true));

				--碰碰牌型
				if ((bLianCard==false)&&(bPengCard==true))
					dwChiHuKind|=CHK_PENG_PENG;
				if ((bLianCard==true)&&(bPengCard==true))
					dwChiHuKind|=CHK_JI_HU;
				if ((bLianCard==true)&&(bPengCard==false))
					dwChiHuKind|=CHK_PING_HU;
			}
		}
		else
		{
			if(0x03 == cbCardIndexTemp[byGodsCardIndex])  -- 有三财神，没有其他胡牌
			{
				if (!bIsBaDui)
				{
					dwChiHuKind |= CHK_YING_PAI;
				}
				else
				{
					dwChiHuKind |= CHK_SAN_GODS;
				}
			}
			else if (bIsBaDuiFallback)  -- 才神归位，胡八对
			{
				dwChiHuKind |= CHK_YING_PAI;
			}
		}

		--牌权判断
		--if (IsQingYiSe(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuRight|=CHR_QING_YI_SE;

		--大胡牌型
		--if (IsQiXiaoDui(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuKind|=CHK_QI_XIAO_DUI;
		--if (IsShiSanYao(cbCardIndexTemp,WeaveItem,cbWeaveCount)==true) dwChiHuKind|=CHK_SHI_SAN_YAO;

		if (bIsBaDui)
		{
			if (cbCardIndexTemp[byGodsCardIndex]>0x00)
			{
				dwChiHuKind|=CHK_BA_DUI;
			}
			else
			{
				dwChiHuKind|=CHK_YING_BA_DUI;
			}
		}

		--结果判断
		if (dwChiHuKind!=CHK_NULL)
		{
			ChiHuResult.dwChiHuKind |= dwChiHuKind;
			ChiHuResult.dwChiHuRight |= dwChiHuRight;
			--变量定义
			if ((CHK_YING_BA_DUI == (CHK_YING_BA_DUI&dwChiHuKind))
				|| (CHK_SAN_GODS == (CHK_SAN_GODS&dwChiHuKind))
				|| (CHK_SINGLE_PAI == (CHK_SINGLE_PAI&dwChiHuKind)))
			{
				ChiHuResult.dwWinTimes = 4;
			}
			else if (CHK_YING_PAI == (CHK_YING_PAI&dwChiHuKind))
			{
				ChiHuResult.dwWinTimes = 2;
			}
			else
			{
				ChiHuResult.dwWinTimes = 1;
			}

			if (4 != ChiHuResult.dwWinTimes)
			{
				if (CHR_DI == (dwChiHuRight&CHR_DI))
				{
					ChiHuResult.dwWinTimes = 4;
				}
				if (CHR_TIAN == (dwChiHuRight&CHR_TIAN))
				{
					ChiHuResult.dwWinTimes = 4;
				}
			}
			return WIK_CHI_HU;
		}

		return WIK_NULL;
	}
	--十三夭牌
	bool CGameLogic::IsShiSanYao(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount)
	{
		--组合判断
		if (cbWeaveCount!=0) return false;

		--扑克判断
		bool bCardEye=false;

		--一九判断
		for (BYTE i=0;i<27;i+=9)
		{
			--无效判断
			if (cbCardIndex[i]==0) return false;
			if (cbCardIndex[i+8]==0) return false;

			--牌眼判断
			if ((bCardEye==false)&&(cbCardIndex[i]==2)) bCardEye=true;
			if ((bCardEye==false)&&(cbCardIndex[i+8]==2)) bCardEye=true;
		}

		--番子判断
		for (BYTE i=27;i<MAX_INDEX;i++)
		{
			if (cbCardIndex[i]==0) return false;
			if ((bCardEye==false)&&(cbCardIndex[i]==2)) bCardEye=true;
		}

		--牌眼判断
		if (bCardEye==false) return false;

		return true;
	}

	--清一色牌
	bool CGameLogic::IsQingYiSe(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbItemCount)
	{
		--胡牌判断
		BYTE cbCardColor=0xFF;

		for (BYTE i=0;i<MAX_INDEX;i++)
		{
			if (cbCardIndex[i]!=0)
			{
				--花色判断
				if (cbCardColor!=0xFF)
					return false;

				--设置花色
				cbCardColor=(SwitchToCardData(i)&MASK_COLOR);

				--设置索引
				i=(i/9+1)*9-1;
			}
		}

		--组合判断
		for (BYTE i=0;i<cbItemCount;i++)
		{
			BYTE cbCenterCard=WeaveItem[i].cbCenterCard;
			if ((cbCenterCard&MASK_COLOR)!=cbCardColor)
				return false;
		}

		return true;
	}
	--七小对牌
	bool CGameLogic::IsQiXiaoDui(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount)
	{
		--组合判断
		if (cbWeaveCount!=0)
			return false;

		--扑克判断
		for (BYTE i=0;i<MAX_INDEX;i++)
		{
			BYTE cbCardCount=cbCardIndex[i];
			if ((cbCardCount!=0)&&(cbCardCount!=2)&&(cbCardCount!=4))
				return false;
		}

		return true;
	}

	-- 八对
	bool CGameLogic::IsBaDui(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount)
	{
		--组合判断
		if (cbWeaveCount!=0)
			return false;
		--扑克判断
		int iCount  = 0;
		for (BYTE i=0;i<MAX_INDEX;i++)
		{
			BYTE cbCardCount=cbCardIndex[i];
			if (0x00 != (cbCardCount%2))
			{
				++iCount;
				if (iCount>1)
				{
					return false;
				}
			}
		}
		return true;
	}


	--扑克转换
	BYTE CGameLogic::SwitchToCardData(BYTE cbCardIndex)
	{
		ASSERT(cbCardIndex<MAX_INDEX);
		if (m_byGodsCardData>0)
		{
			if (SwitchToCardIndex(BAIBAN_CARD_DATA) == cbCardIndex)
			{
				return BAIBAN_CARD_DATA;
			}
			else if (SwitchToCardIndex(m_byGodsCardData) == cbCardIndex)
			{
				return m_byGodsCardData;
			}
			else
			{
				return ((cbCardIndex/9)<<4)|(cbCardIndex%9+1);
			}
		}
		return ((cbCardIndex/9)<<4)|(cbCardIndex%9+1);
	}

	--扑克转换
	BYTE CGameLogic::SwitchToCardIndex(BYTE cbCardData)
	{
		ASSERT(IsValidCard(cbCardData));
		if (m_byGodsCardData>0)
		{
			if (BAIBAN_CARD_DATA == cbCardData)    -- 将白板跟财神交换
			{
				cbCardData = m_byGodsCardData;
			}
			else if (m_byGodsCardData == cbCardData)
			{
				cbCardData = BAIBAN_CARD_DATA;
			}
		}
		return ((cbCardData&MASK_COLOR)>>4)*9+(cbCardData&MASK_VALUE)-1;
	}

	--扑克转换
	BYTE CGameLogic::SwitchToCardData(BYTE cbCardIndex[MAX_INDEX], BYTE cbCardData[MAX_COUNT])
	{
		BYTE cbPosition=0;
		BYTE byIndex = 0xFF;
		--转换扑克
		if (m_byGodsCardData > 0)
		{
			-- 财神放在第一位
			byIndex = SwitchToCardIndex(m_byGodsCardData);
			if (0 != cbCardIndex[byIndex]) -- 首先把财神 加入
			{
				for (BYTE j=0;j<cbCardIndex[byIndex];j++)
				{
					ASSERT(cbPosition<MAX_COUNT);
					cbCardData[cbPosition++]=SwitchToCardData(byIndex);
				}
			}
		}
		for (BYTE i=0;i<MAX_INDEX;i++)
		{
			if (byIndex == i)
			{
				continue ;
			}

			if (cbCardIndex[i]!=0)
			{
				for (BYTE j=0;j<cbCardIndex[i];j++)
				{
					ASSERT(cbPosition<MAX_COUNT);
					cbCardData[cbPosition++]=SwitchToCardData(i);
				}
			}
		}
		return cbPosition;
	}

	void CGameLogic::SetGodsCard(BYTE byCardData)
	{
		m_byGodsCardData = byCardData;
	}

	--扑克转换
	BYTE CGameLogic::SwitchToCardIndex(BYTE cbCardData[], BYTE cbCardCount, BYTE cbCardIndex[MAX_INDEX])
	{
		--设置变量
		ZeroMemory(cbCardIndex,sizeof(BYTE)*MAX_INDEX);

		--转换扑克
		for (BYTE i=0;i<cbCardCount;i++)
		{
			ASSERT(IsValidCard(cbCardData[i]));
			cbCardIndex[SwitchToCardIndex(cbCardData[i])]++;
		}

		return cbCardCount;
	}

	--分析扑克
	bool CGameLogic::AnalyseCard(BYTE cbCardIndex[MAX_INDEX], tagWeaveItem WeaveItem[], BYTE cbWeaveCount, CAnalyseItemArray & AnalyseItemArray)
	{
		--计算数目
		BYTE cbCardCount=0;
		for (BYTE i=0;i<MAX_INDEX;i++)
			cbCardCount+=cbCardIndex[i];

		--效验数目
		ASSERT((cbCardCount>=2)&&(cbCardCount<=MAX_COUNT)&&((cbCardCount-2)%3==0));
		if ((cbCardCount<2)||(cbCardCount>MAX_COUNT)||((cbCardCount-2)%3!=0))
			return false;

		--变量定义
		BYTE cbKindItemCount=0;
		tagKindItem KindItem[MAX_COUNT-2];
		ZeroMemory(KindItem,sizeof(KindItem));

		--需求判断
		BYTE cbLessKindItem=(cbCardCount-2)/3;
		ASSERT((cbLessKindItem+cbWeaveCount)==MAX_WEAVE);

		BYTE byGodsIndex = SwitchToCardIndex(m_byGodsCardData);
		--单吊判断
		if (cbLessKindItem==0)
		{
			--效验参数
			ASSERT((cbCardCount==2)&&(cbWeaveCount==MAX_WEAVE));

			--牌眼判断
			for (BYTE i=0;i<MAX_INDEX;i++)
			{
				if ((cbCardIndex[i]==2)
					|| ((cbCardIndex[i]==1)
					&& (i != byGodsIndex)
					&& (cbCardIndex[byGodsIndex]>0)))
				{
					--变量定义
					tagAnalyseItem AnalyseItem;
					ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));

					--设置结果
					for (BYTE j=0;j<cbWeaveCount;j++)
					{
						AnalyseItem.cbWeaveKind[j]=WeaveItem[j].cbWeaveKind;
						AnalyseItem.cbCenterCard[j]=WeaveItem[j].cbCenterCard;
					}
					AnalyseItem.cbCardEye=SwitchToCardData(i);

					--插入结果
					AnalyseItemArray.Add(AnalyseItem);

					return true;
				}
			}
			return false;
		}

		-- 拆分分析
		if (cbCardCount>=3)
		{
			for (BYTE i=0;i<MAX_INDEX;i++)
			{
				--同牌判断
				if (cbCardIndex[i]>=3)
				{
					KindItem[cbKindItemCount].cbCardIndex[0]=i;
					KindItem[cbKindItemCount].cbCardIndex[1]=i;
					KindItem[cbKindItemCount].cbCardIndex[2]=i;
					KindItem[cbKindItemCount].cbWeaveKind=WIK_PENG;
					KindItem[cbKindItemCount++].cbCenterCard=SwitchToCardData(i);
				}

				-- 连牌判断
				if ((i<(MAX_INDEX-9))&&(cbCardIndex[i]>0)&&((i%9)<7))
				{
					for (BYTE j=1;j<=cbCardIndex[i];j++)
					{
						if ((cbCardIndex[i+1]>=j)&&(cbCardIndex[i+2]>=j))
						{
							KindItem[cbKindItemCount].cbCardIndex[0]=i;
							KindItem[cbKindItemCount].cbCardIndex[1]=i+1;
							KindItem[cbKindItemCount].cbCardIndex[2]=i+2;
							KindItem[cbKindItemCount].cbWeaveKind=WIK_LEFT;
							KindItem[cbKindItemCount++].cbCenterCard=SwitchToCardData(i);
						}
					}
				}
			}
		}

		--组合分析
		if (cbKindItemCount>=cbLessKindItem)
		{
			--变量定义
			BYTE cbCardIndexTemp[MAX_INDEX];
			ZeroMemory(cbCardIndexTemp,sizeof(cbCardIndexTemp));

			--变量定义
			BYTE cbIndex[MAX_WEAVE]={0,1,2,3,4};
			tagKindItem * pKindItem[MAX_WEAVE];
			ZeroMemory(&pKindItem,sizeof(pKindItem));

			--开始组合
			do
			{
				--设置变量
				CopyMemory(cbCardIndexTemp,cbCardIndex,sizeof(cbCardIndexTemp));
				for (BYTE i=0;i<cbLessKindItem;i++)
					pKindItem[i]=&KindItem[cbIndex[i]];

				--数量判断
				bool bEnoughCard=true;
				for (BYTE i=0;i<cbLessKindItem*3;i++)
				{
					--存在判断
					BYTE cbCardIndex=pKindItem[i/3]->cbCardIndex[i%3];
					if (cbCardIndexTemp[cbCardIndex]==0)
					{
						bEnoughCard=false;
						break;
					}
					else
						cbCardIndexTemp[cbCardIndex]--;
				}

				--胡牌判断
				if (bEnoughCard==true)
				{
					--牌眼判断
					BYTE cbCardEye=0;
					for (BYTE i=0;i<MAX_INDEX;i++)
					{
						if (cbCardIndexTemp[i]==2)
						{
							cbCardEye=SwitchToCardData(i);
							break;
						}
					}

					--组合类型
					if (cbCardEye!=0)
					{
						--变量定义
						tagAnalyseItem AnalyseItem;
						ZeroMemory(&AnalyseItem,sizeof(AnalyseItem));

						--设置组合
						for (BYTE i=0;i<cbWeaveCount;i++)
						{
							AnalyseItem.cbWeaveKind[i]=WeaveItem[i].cbWeaveKind;
							AnalyseItem.cbCenterCard[i]=WeaveItem[i].cbCenterCard;
						}

						--设置牌型
						for (BYTE i=0;i<cbLessKindItem;i++)
						{
							AnalyseItem.cbWeaveKind[i+cbWeaveCount]=pKindItem[i]->cbWeaveKind;
							AnalyseItem.cbCenterCard[i+cbWeaveCount]=pKindItem[i]->cbCenterCard;
						}

						--设置牌眼
						AnalyseItem.cbCardEye=cbCardEye;

						--插入结果
						AnalyseItemArray.Add(AnalyseItem);
					}
				}

				--设置索引
				if (cbIndex[cbLessKindItem-1]==(cbKindItemCount-1))
				{
					for (BYTE i=cbLessKindItem-1;i>0;i--)
					{
						if ((cbIndex[i-1]+1)!=cbIndex[i])
						{
							BYTE cbNewIndex=cbIndex[i-1];
							for (BYTE j=(i-1);j<cbLessKindItem;j++)
								cbIndex[j]=cbNewIndex+j-i+2;
							break;
						}
					}
					if (i==0)
						break;
				}
				else
					cbIndex[cbLessKindItem-1]++;

			} while (true);

		}

		return (AnalyseItemArray.GetCount()>0);
	}

return GameLogic

local cmd =  {}

cmd.RES_PATH 				= "game/yule/mahjongwzer/res/"
--
--公共宏定义

cmd.KIND_ID					=	306									 --游戏 I D
cmd.GAME_PLAYER				=	2									 --游戏人数
cmd.GAME_NAME				=	"传统温州麻将"						--游戏名字
cmd.GAME_GENRE			=		(GAME_GENRE_SCORE or GAME_GENRE_MATCH or GAME_GENRE_GOLD)	--游戏类型

cmd.VERSION_SERVER	=		    appdf.VersionValue(6,0,3)			 --程序版本
cmd.VERSION_CLIENT	=			appdf.VersionValue(6,0,3)			 --程序版本

cmd.NAME_LEN				=	32
--------------------------------------------------------------------------
--游戏状态
cmd.GAME_STATUS_PLAY	=100 										--全局定义 Define.h
cmd.GS_MJ_FREE			=		0  --GAME_STATUS_FREE				-- 空闲状态
cmd.GS_MJ_MAIDI			=	  	cmd.GAME_STATUS_PLAY+1				-- 买庄状态
cmd.GS_MJ_PLAY			=	   	cmd.GAME_STATUS_PLAY				-- 游戏状态

--常量定义
cmd.MAX_WEAVE				=	5									--最大组合
cmd.MAX_INDEX				=	34									--最大索引
cmd.MAX_COUNT				=	17									--最大数目
cmd.MAX_REPERTORY			=	136									--最大库存

cmd.GAME_SCENE_FREE			=	0  --GAME_STATUS_FREE				--等待开始
--------------------------------------------------------------------------
--[[
class CDebugString
{
public:
	CDebugString(const TCHAR *pszFunctionName, int iLineNo)
		:m_pszFunctionName(pszFunctionName),m_iLineNo(iLineNo)
	{
	}
public:
	virtual ~CDebugString(void){}

	void operator()(const TCHAR *pszFmt, ...) const
	{
		--SYSTEMTIME sys;
		--GetLocalTime( &sys );
		TCHAR szData[1024]={0};
		TCHAR szMsg[1024]={0};
		va_list args;
		va_start(args, pszFmt);
		_sntprintf(szData, sizeof(szData) - 2, pszFmt, args);
		va_end(args);
		--_sntprintf(szMsg, sizeof(szMsg), TEXT("[line: %04d][Function: %s][Time: %02u:%02u:%02u.%03u] %s"),
		--	m_iLineNo, m_pszFunctionName, sys.wHour,sys.wMinute,sys.wSecond,sys.wMilliseconds, szData);
		_sntprintf(szMsg, sizeof(szMsg), TEXT("[line: %04d][Function: %s] %s\n"),
			m_iLineNo, m_pszFunctionName, szData);
		OutputDebugString(szMsg);
	}
protected:
	const TCHAR *m_pszFunctionName;
	const int    m_iLineNo;
};

cmd._STR2WSTR_(str)      =    TEXT(##str)
cmd.__UN_FUCNTION__      =    _STR2WSTR_(__FUNCTION__)
cmd.OUTPUT_DEBUG_STRING  =   CDebugString(__UN_FUCNTION__, __LINE__)
--]]
--------------------------------------------------------------------------

--组合子项
cmd.CMD_WeaveItem=
{
	{k = "cbWeaveKind", t = "byte"},				--组合类型
	{k = "cbCenterCard", t = "byte"},				--中心扑克
	{k = "cbPublicCard", t = "byte"},				--公开标志
	{k = "wProvideUser", t = "word"}				--供应用户
}

--------------------------------------------------------------------------
--服务器命令结构

cmd.SUB_S_GAME_START		=	100									--游戏开始
cmd.SUB_S_OUT_CARD			=	101									--出牌命令
cmd.SUB_S_SEND_CARD			=	102									--发送扑克
cmd.SUB_S_LISTEN_CARD		=	103									--听牌命令
cmd.SUB_S_OPERATE_NOTIFY	=	104									--操作提示
cmd.SUB_S_OPERATE_RESULT	=	105									--操作命令
cmd.SUB_S_GAME_END			=	106									--游戏结束
cmd.SUB_S_TRUSTEE			=	107									--用户托管
cmd.SUB_S_DINGDI			=	108									-- 玩家顶底
cmd.SUB_S_GAME_PLAY			=	109									-- 游戏正式开始

--游戏状态
cmd.CMD_S_StatusFree=
{
	{k = "lCellScore", t = "int"},							--基础金币
	{k = "wBankerUser", t = "word"},						--庄家用户
	{k = "bTrustee", t = "bool", l = {cmd.GAME_PLAYER}},		--是否托管
	{k = "szRoomName", t = "string", s = 32}
}

cmd.CMD_S_StatusMaiDi=
{
	{k = "lCellScore", t = "int"},							--基础金币
	{k = "lBaseScore", t = "int"},							--底分
	{k = "wBankerUser", t = "word"},						--庄家用户
	{k = "bTrustee", t = "bool", l = {cmd.GAME_PLAYER}},		--是否托管
	{k = "bBankerMaiDi", t = "bool"},	    			-- 庄家是否需要买底
	{k = "bMeDingDi", t = "bool"},	    			-- 自己是否需要顶底
	{k = "szRoomName", t = "string", s = 32}
}

--游戏状态
cmd.CMD_S_StatusPlay=
{
	--游戏变量
	{k = "lCellScore", t = "int"},								-- 单元积分
	{k = "wSiceCount1", t = "word"},							-- 骰子点数
	{k = "wSiceCount2", t = "word"},							-- 骰子点数
	{k = "wSiceCount3", t = "word"},							-- 骰子点数

	{k = "wBankerUser", t = "word"},							--庄家用户
	{k = "wCurrentUser", t = "word"},							--当前用户

	--状态变量
  	{k="cbActionCard",t="byte"},									--动作扑克
  	{k="cbActionMask",t="byte"},									--动作掩码
  	{k="cbHearStatus",t="byte", l = {cmd.GAME_PLAYER}},									--听牌状态
  	{k="cbLeftCardCount",t="byte"},								--剩余数目
	{k = "bTrustee", t = "bool", l = {cmd.GAME_PLAYER}},		--是否托管

	--出牌信息
	{k = "wOutCardUser", t = "word"},							--出牌用户
	{k="cbOutCardData",t="byte"},									--出牌扑克
  	{k="cbDiscardCount",t="byte", l = {cmd.GAME_PLAYER}},				--丢弃数目
  	{k="cbDiscardCard",t="byte", l = {60,60}},			--丢弃记录
 	 {k="byDingDi",t="byte", l = {cmd.GAME_PLAYER}},	--顶底结果
  	{k="byOutCardIndex",t="byte", l = {cmd.MAX_INDEX}},	          -- 已经打出的牌

	--扑克数据
	{k="cbCardCount",t="byte"},								--扑克数目
 	 {k="cbCardData",t="byte", l = {cmd.MAX_COUNT}},	   			--扑克列表
	{k="cbSendCardData",t="byte"},						--发送扑克
	{k="byGodsCardData",t="byte"},

	--组合扑克
 	 {k="cbWeaveCount",t="byte", l = {cmd.GAME_PLAYER}},				--组合数目
	{k="WeaveItemArray", t = "table", d = cmd.CMD_WeaveItem, l = {5, 5}},	--组合扑克
	--{k="szRoomName", t = "tchar", s = 32}
	{k="szRoomName", t = "string", s = 32}
}

--游戏开始
cmd.CMD_S_GameStart=
{
	{k = "wBankerUser", t = "word"},							--庄家用户
	{k="bBankerCount",t="byte"},
	{k = "lBaseScore", t = "int"},								-- 底分
	{k = "bMaiDi", t = "bool"},    								-- 庄家是否可以买底
	{k = "bTrustee", t = "bool", l = {cmd.GAME_PLAYER}}		--是否托管
}

cmd.CMD_S_GamePlay=
{
	{k = "wSiceCount1", t = "word"},							-- 骰子点数
	{k = "wSiceCount2", t = "word"},							-- 骰子点数
	{k = "wSiceCount3", t = "word"},							-- 骰子点数
	{k = "wCurrentUser", t = "word"},							-- 当前用户
	{k="cbUserAction",t="byte"},									-- 用户动作
	{k="byGodsCardData",t="byte"},	              -- 财神牌
	{k ="byUserDingDi", t = "byte", l = {cmd.GAME_PLAYER}},               -- 玩家顶底情况
	{k ="cbCardData", t = "byte", l = {17,17}}	  -- 扑克列表
}

--出牌命令
cmd.CMD_S_OutCard=
{
	{k="wOutCardUser",t="word"},								--出牌用户
	{k="cbOutCardData",t="byte"}								--出牌扑克
}

--发送扑克
cmd.CMD_S_SendCard=
{
	{k="cbCardData",t="byte"},								--扑克数据
	{k="cbActionMask",t="byte"},							--动作掩码
	{k="wCurrentUser",t="word"}								--当前用户
}

--听牌命令
cmd.CMD_S_ListenCard=
{
	{k="wListenUser",t="word"}								--听牌用户
}

--操作提示
cmd.CMD_S_OperateNotify=
{
	{k="wResumeUser",t="word"},								--还原用户
	{k="cbActionMask",t="byte"},						--动作掩码
	{k="cbActionCard",t="byte"}					--动作扑克
}

--操作命令
cmd.CMD_S_OperateResult=
{
	{k="wOperateUser",t="word"},						--操作用户
	{k="wProvideUser",t="word"},						--供应用户
	{k="cbOperateCode",t="byte"},						--操作代码
	{k="cbOperateCard",t="byte"}						--操作扑克
}

--游戏结束
cmd.CMD_S_GameEnd=
{
	{k = "lGameTax", t = "int"},								--游戏税收
	--结束信息
	{k="wProvideUser",t="word"},								--供应用户
	{k="cbProvideCard",t="byte"},								--供应扑克
	{k ="dwChiHuKind", t = "dword", l = {cmd.GAME_PLAYER}}, 	--胡牌类型
	{k ="dwChiHuRight", t = "dword", l = {cmd.GAME_PLAYER}}, 	--胡牌类型
	{k ="byDingDi", t = "byte", l = {cmd.GAME_PLAYER}},

	--积分信息
	{k ="lGameScore", t = "int", l = {cmd.GAME_PLAYER}},		--游戏积分
	{k ="lGodsScore", t = "int", l = {cmd.GAME_PLAYER}},		--游戏积分

	--扑克信息
	{k ="cbCardCount", t = "byte", l = {cmd.GAME_PLAYER}},		--扑克数目
	{k ="cbCardData", t = "byte", l = {17,17}}					--扑克数据
}
--用户托管
cmd.CMD_S_Trustee=
{
	{k = "bTrustee", t = "bool"},								--是否托管
	{k = "wChairID", t = "word"}								--托管用户
}

--用户托管
cmd.CMD_S_DingDi=
{
	{k = "byMaiDi", t = "byte"},							-- 庄家买底结果
	{k = "wChairID", t = "word"},							-- 顶底用户
	{k = "bDingDi", t = "bool"}		    	      -- 闲家是否可以顶底
}

--------------------------------------------------------------------------
--客户端命令结构

cmd.SUB_C_OUT_CARD			=	1									--出牌命令
cmd.SUB_C_LISTEN_CARD		=	2									--听牌命令
cmd.SUB_C_OPERATE_CARD		=	3									--操作扑克
cmd.SUB_C_TRUSTEE			= 4										--用户托管
cmd.SUB_C_SET_CARD     		= 5         					        -- 取牌命令
cmd.SUB_C_DINGDI       		= 6           			   		        -- 顶底
cmd.SUB_C_CHECK_SUPER		= 7

--游戏定时器
cmd.IDI_START_GAME			=	200									--开始定时器
cmd.IDI_OPERATE_CARD		=	201									--操作定时器
cmd.IDI_DINGDI_CARD			=  202									--操作定时器

--游戏定时器
--cmd.TIME_START_GAME			=	60									--开始定时器
cmd.TIME_START_GAME			=	30									--开始定时器
cmd.TIME_HEAR_STATUS		=	15									--出牌定时器
cmd.TIME_OPERATE_CARD		=	15									--操作定时器


--出牌命令
cmd.CMD_C_OutCard=
{
	{k = "cbCardData", t = "byte"}						--扑克数据
}

--操作命令
cmd.CMD_C_OperateCard=
{
	{k = "cbOperateCode", t = "byte"},				--操作代码
	{k = "cbOperateCard", t = "byte"}					--操作扑克
}
--用户托管
cmd.CMD_C_Trustee=
{
	{k = "bTrustee", t = "bool"}							--是否托管
}

cmd.CMD_C_DingDi=
{
	{k = "byDingDi", t = "byte"}							-- 顶底是否，如果是庄家表示买底
}
--------------------------------------------------------------------------

return cmd

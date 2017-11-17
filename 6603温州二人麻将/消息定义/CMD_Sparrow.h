#ifndef CMD_SPARROW_HEAD_FILE
#define CMD_SPARROW_HEAD_FILE

//////////////////////////////////////////////////////////////////////////
//公共宏定义

#define KIND_ID						306								//游戏 I D
#define GAME_PLAYER					2									//游戏人数
#define GAME_NAME					TEXT("传统温州麻将")					//游戏名字
#define GAME_GENRE					(GAME_GENRE_SCORE|GAME_GENRE_MATCH|GAME_GENRE_GOLD)	//游戏类型

#define VERSION_SERVER			    	PROCESS_VERSION(6,0,3)				//程序版本
#define VERSION_CLIENT				    PROCESS_VERSION(6,0,3)				//程序版本

#define NAME_LEN					32
//////////////////////////////////////////////////////////////////////////
//游戏状态
#define GS_MJ_FREE					GAME_STATUS_FREE								// 空闲状态
#define GS_MJ_MAIDI				    (GAME_STATUS_PLAY+1)						// 买庄状态
#define GS_MJ_PLAY				   GAME_STATUS_PLAY						// 游戏状态

//常量定义
#define MAX_WEAVE					5									//最大组合
#define MAX_INDEX					34									//最大索引
#define MAX_COUNT					17									//最大数目
#define MAX_REPERTORY				136									//最大库存

#define GAME_SCENE_FREE				GAME_STATUS_FREE					//等待开始
#ifndef OUTPUT_DEBUG_STRING
//////////////////////////////////////////////////////////////////////////
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
		//SYSTEMTIME sys; 
		//GetLocalTime( &sys );
		TCHAR szData[1024]={0};
		TCHAR szMsg[1024]={0};
		va_list args;
		va_start(args, pszFmt);
		_sntprintf(szData, sizeof(szData) - 2, pszFmt, args);
		va_end(args);
		//_sntprintf(szMsg, sizeof(szMsg), TEXT("[line: %04d][Function: %s][Time: %02u:%02u:%02u.%03u] %s"),
		//	m_iLineNo, m_pszFunctionName, sys.wHour,sys.wMinute,sys.wSecond,sys.wMilliseconds, szData);
		_sntprintf(szMsg, sizeof(szMsg), TEXT("[line: %04d][Function: %s] %s\n"),
			m_iLineNo, m_pszFunctionName, szData);
		OutputDebugString(szMsg);
	}
protected:
	const TCHAR *m_pszFunctionName;
	const int    m_iLineNo;
};

#define _STR2WSTR_(str)          TEXT(##str)
#define  __UN_FUCNTION__    _STR2WSTR_(__FUNCTION__)
#define OUTPUT_DEBUG_STRING     CDebugString(__UN_FUCNTION__, __LINE__)
#endif
//////////////////////////////////////////////////////////////////////////

//组合子项
struct CMD_WeaveItem
{
	BYTE							cbWeaveKind;						//组合类型
	BYTE							cbCenterCard;						//中心扑克
	BYTE							cbPublicCard;						//公开标志
	WORD							wProvideUser;						//供应用户
};

//////////////////////////////////////////////////////////////////////////
//服务器命令结构

#define SUB_S_GAME_START			100									//游戏开始
#define SUB_S_OUT_CARD				101									//出牌命令
#define SUB_S_SEND_CARD				102									//发送扑克
#define SUB_S_LISTEN_CARD			103									//听牌命令
#define SUB_S_OPERATE_NOTIFY		104									//操作提示
#define SUB_S_OPERATE_RESULT		105									//操作命令
#define SUB_S_GAME_END				106									//游戏结束
#define SUB_S_TRUSTEE				107									//用户托管
#define SUB_S_DINGDI				108									// 玩家顶底
#define SUB_S_GAME_PLAY				109									// 游戏正式开始

//游戏状态
struct CMD_S_StatusFree
{
	__int64							lCellScore;							//基础金币
	WORD							wBankerUser;						//庄家用户
	bool							bTrustee[GAME_PLAYER];						//是否托管
	TCHAR							szRoomName[32];
};

struct CMD_S_StatusMaiDi
{
	__int64							lCellScore;							//基础金币
	__int64                         lBaseScore;                         // 底分
	WORD							wBankerUser;						//庄家用户
	bool							bTrustee[GAME_PLAYER];				// 是否托管
	bool                            bBankerMaiDi;                       // 庄家是否需要买底
	bool                            bMeDingDi;                          // 自己是否需要顶底
	TCHAR							szRoomName[32];
};

//游戏状态
struct CMD_S_StatusPlay
{
	//游戏变量
	__int64							lCellScore;									// 单元积分
	WORD							wSiceCount1;								// 骰子点数
	WORD							wSiceCount2;								// 骰子点数
	WORD							wSiceCount3;								// 骰子点数

	WORD							wBankerUser;								//庄家用户
	WORD							wCurrentUser;								//当前用户

	//状态变量
	BYTE							cbActionCard;								//动作扑克
	BYTE							cbActionMask;								//动作掩码
	BYTE							cbHearStatus[GAME_PLAYER];					//听牌状态
	BYTE							cbLeftCardCount;							//剩余数目
	bool							bTrustee[GAME_PLAYER];						//是否托管

	//出牌信息
	WORD							wOutCardUser;								//出牌用户
	BYTE							cbOutCardData;								//出牌扑克
	BYTE							cbDiscardCount[GAME_PLAYER];				//丢弃数目
	BYTE							cbDiscardCard[GAME_PLAYER][60];				//丢弃记录
	BYTE							byDingDi[GAME_PLAYER];						//顶底结果
	BYTE                            byOutCardIndex[MAX_INDEX];                  // 已经打出的牌

	//扑克数据
	BYTE							cbCardCount;								//扑克数目
	BYTE							cbCardData[MAX_COUNT];						//扑克列表
	BYTE							cbSendCardData;								//发送扑克
	BYTE                            byGodsCardData;

	//组合扑克
	BYTE							cbWeaveCount[GAME_PLAYER];					//组合数目
	CMD_WeaveItem					WeaveItemArray[GAME_PLAYER][MAX_WEAVE];		//组合扑克
	TCHAR							szRoomName[32];
};

//游戏开始
struct CMD_S_GameStart
{
	WORD							wBankerUser;								//庄家用户
	BYTE							bBankerCount;
	__int64							lBaseScore;									// 底分
	bool                            bMaiDi;                                     // 庄家是否可以买底
	bool							bTrustee[GAME_PLAYER];						//是否托管
};

struct CMD_S_GamePlay
{
	WORD							wSiceCount1;								// 骰子点数
	WORD							wSiceCount2;								// 骰子点数
	WORD							wSiceCount3;								// 骰子点数
	WORD							wCurrentUser;								// 当前用户
	BYTE							cbUserAction;								// 用户动作
	BYTE                            byGodsCardData;                             // 财神牌
	BYTE                            byUserDingDi[GAME_PLAYER];                  // 玩家顶底情况
	BYTE							cbCardData[GAME_PLAYER][MAX_COUNT];			// 扑克列表
};

//出牌命令
struct CMD_S_OutCard
{
	WORD							wOutCardUser;						//出牌用户
	BYTE							cbOutCardData;						//出牌扑克
};

//发送扑克
struct CMD_S_SendCard
{
	BYTE							cbCardData;							//扑克数据
	BYTE							cbActionMask;						//动作掩码
	WORD							wCurrentUser;						//当前用户
};

//听牌命令
struct CMD_S_ListenCard
{
	WORD							wListenUser;						//听牌用户
};

//操作提示
struct CMD_S_OperateNotify
{
	WORD							wResumeUser;						//还原用户
	BYTE							cbActionMask;						//动作掩码
	BYTE							cbActionCard;						//动作扑克
};

//操作命令
struct CMD_S_OperateResult
{
	WORD							wOperateUser;						//操作用户
	WORD							wProvideUser;						//供应用户
	BYTE							cbOperateCode;						//操作代码
	BYTE							cbOperateCard;						//操作扑克
};

//游戏结束
struct CMD_S_GameEnd
{
	__int64							lGameTax;							//游戏税收
	//结束信息
	WORD							wProvideUser;						//供应用户
	BYTE							cbProvideCard;						//供应扑克
	DWORD							dwChiHuKind[GAME_PLAYER];			//胡牌类型
	DWORD							dwChiHuRight[GAME_PLAYER];			//胡牌类型
	BYTE                            byDingDi[GAME_PLAYER];

	//积分信息
	__int64						lGameScore[GAME_PLAYER];			//游戏积分
	__int64						lGodsScore[GAME_PLAYER];			//游戏积分

	//扑克信息
	BYTE							cbCardCount[GAME_PLAYER];			//扑克数目
	BYTE							cbCardData[GAME_PLAYER][MAX_COUNT];	//扑克数据
};
//用户托管
struct CMD_S_Trustee
{
	bool							bTrustee;							//是否托管
	WORD							wChairID;							//托管用户
};

//用户托管
struct CMD_S_DingDi
{
	BYTE							byMaiDi;							// 庄家买底结果
	WORD							wChairID;							// 顶底用户
	bool                            bDingDi;                            // 闲家是否可以顶底                 
};

//////////////////////////////////////////////////////////////////////////
//客户端命令结构

#define SUB_C_OUT_CARD				1									//出牌命令
#define SUB_C_LISTEN_CARD			2									//听牌命令
#define SUB_C_OPERATE_CARD			3									//操作扑克
#define SUB_C_TRUSTEE				4									//用户托管
#define SUB_C_SET_CARD              5                                   // 取牌命令
#define SUB_C_DINGDI                6                                   // 顶底
#define SUB_C_CHECK_SUPER			7

//出牌命令
struct CMD_C_OutCard
{
	BYTE							cbCardData;							//扑克数据
};

//操作命令
struct CMD_C_OperateCard
{
	BYTE							cbOperateCode;						//操作代码
	BYTE							cbOperateCard;						//操作扑克
};
//用户托管
struct CMD_C_Trustee
{
	bool							bTrustee;							//是否托管	
};

struct CMD_C_DingDi
{
	BYTE 							byDingDi;							// 顶底是否，如果是庄家表示买底	
};
//////////////////////////////////////////////////////////////////////////

#endif
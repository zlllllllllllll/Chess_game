#pragma once

#include "Stdafx.h"
#include "..\消息定义\GameLogic.h"
#include "GameClientView.h"

//////////////////////////////////////////////////////////////////////////

//游戏对话框
class CGameClientEngine : public CGameFrameEngine
{
	//友元声明
	friend class CGameClientView;
	//用户变量
protected:
	WORD							m_wBankerUser;						//庄家用户
	WORD							m_wCurrentUser;						//当前用户

	bool							m_bChineseVoice;

		BYTE							m_cbUserAction;						//玩家动作
	
	//状态变量
protected:
	bool							m_bHearStatus;						//听牌状态
	bool							m_bWillHearStatus;					//即将听牌

	//托管变量
protected:
	bool							m_bStustee;							//托管标志
	WORD							m_wTimeOutCount;					//超时次数

	//堆立变量
protected:
	WORD							m_wHeapHand;						//堆立头部
	WORD							m_wHeapTail;						//堆立尾部
	BYTE							m_cbHeapCardInfo[4][2];				//堆牌信息

	//扑克变量
protected:
	BYTE							m_cbLeftCardCount;					//剩余数目
	BYTE							m_cbCardIndex[MAX_INDEX];			//手中扑克

	//组合扑克
protected:
	BYTE							m_cbWeaveCount[GAME_PLAYER];		//组合数目
	tagWeaveItem					m_WeaveItemArray[GAME_PLAYER][MAX_WEAVE];	//组合扑克

	//出牌信息
protected:
	WORD							m_wOutCardUser;						//出牌用户
	BYTE							m_cbOutCardData;					//出牌扑克
	BYTE							m_cbDiscardCount[GAME_PLAYER];		//丢弃数目
	BYTE							m_cbDiscardCard[GAME_PLAYER][55];	//丢弃记录
	BYTE                            m_bySicboAnimCount;


	//控件变量
protected:
	CGameLogic                      m_GameLogic;						//游戏逻辑
	CGameClientView					m_GameClientView;					//游戏视图
	const tagServerAttribute		*pServerAttribute ;

	CMD_S_GamePlay   m_sGamePlay;  // 游戏发牌消息
	
	//函数定义
public:
	//构造函数
	CGameClientEngine();
	//析构函数
	virtual ~CGameClientEngine();

	//常规继承
public:
	//创建函数
	virtual bool OnInitGameEngine();
	//重置函数
	virtual bool OnResetGameEngine();
	//游戏设置
	virtual void OnGameOptionSet();
public:
	virtual bool OnEventGameClockKill(WORD wChairID);
	//时钟信息
	virtual bool OnEventGameClockInfo(WORD wChairID, UINT nElapse, WORD wClockID);

	//游戏事件
public:
	//旁观消息
	virtual bool OnEventLookonMode(VOID * pData, WORD wDataSize);
	//游戏消息
	virtual bool OnEventGameMessage(WORD wSubCmdID, VOID * pData, WORD wDataSize);
	//场景消息
	virtual bool OnEventSceneMessage(BYTE cbGameStatus, bool bLookonUser, VOID * pData, WORD wDataSize);
	virtual void OnLookonViewChange(bool bLookon);
	//消息处理
protected:
	//游戏开始
	bool OnSubGameStart(const void * pBuffer, WORD wDataSize);
	//用户听牌
	bool OnSubListenCard(const void * pBuffer, WORD wDataSize);
	//用户出牌
	bool OnSubOutCard(const void * pBuffer, WORD wDataSize);
	//发牌消息
	bool OnSubSendCard(const void * pBuffer, WORD wDataSize);
	//操作提示
	bool OnSubOperateNotify(const void * pBuffer, WORD wDataSize);
	//操作结果
	bool OnSubOperateResult(const void * pBuffer, WORD wDataSize);
	//游戏结束
	bool OnSubGameEnd(const void * pBuffer, WORD wDataSize);
	//用户托管
	bool OnSubTrustee(const void * pBuffer,WORD wDataSize);
	// 庄家买底
	bool OnSubDingDi(const void * pBuffer,WORD wDataSize);
	bool OnSubGamePlay(const void * pBuffer,WORD wDataSize);
	//辅助函数
protected:
	//播放声音
	void PlayCardSound(WORD wChairID,BYTE cbCardData);
	//播放声音
	void PlayActionSound(WORD wChairID,BYTE cbAction);
	//出牌判断
	bool VerdictOutCard(BYTE cbCardData);
	//扣除扑克
	void DeductionTableCard(bool bHeadCard);
	//显示控制
	bool ShowOperateControl(BYTE cbUserAction, BYTE cbActionCard);

	//消息映射
protected:
	//开始消息
	LRESULT OnStart(WPARAM wParam, LPARAM lParam);
	//出牌操作
	LRESULT OnOutCard(WPARAM wParam, LPARAM lParam);
	LRESULT OnOutInvalidCard(WPARAM wParam,LPARAM lParam);
	//听牌操作
	LRESULT OnListenCard(WPARAM wParam, LPARAM lParam);
	//扑克操作
	LRESULT OnCardOperate(WPARAM wParam, LPARAM lParam);
	//拖管控制
	LRESULT OnStusteeControl(WPARAM wParam, LPARAM lParam);
	LRESULT OnDingDi(WPARAM wParam, LPARAM lParam);
	LRESULT OnDispatchCard(WPARAM wParam, LPARAM lParam);
	WORD SwitchHeapViewChairID(WORD wChairID);

	DECLARE_MESSAGE_MAP()
public:
	bool IsFreeze(void);
};

//////////////////////////////////////////////////////////////////////////

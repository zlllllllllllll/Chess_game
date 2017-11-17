#pragma once

#include "Stdafx.h"
#include "ControlWnd.h"
#include "CardControl.h"
#include "ScoreControl.h"

//////////////////////////////////////////////////////////////////////////
//消息定义

#define IDM_START					(WM_USER+100)						//开始消息
#define IDM_OUT_CARD				(WM_USER+101)						//出牌消息
#define IDM_TRUSTEE_CONTROL			(WM_USER+102)						//托管控制
#define IDM_DING_DI			        (WM_USER+103)						// 买底，顶底
#define IDM_DISPATCH_CARD           (WM_USER + 104)                    // 玩家发牌
#define IDM_OUT_INVALID_CARD		(WM_USER+105)

#define IDI_DISC_EFFECT					102								//丢弃效果

typedef struct tagBall
{
	double dbX;      // x坐标
	double dbY;      // y坐标
	double dbWidth;  // 宽度
	double dbHeight; // 高度
	double dbDx;     // x加速
	double dbDy;     // y加速
	int iIndex;      // 索引
}BALL;
typedef CArray<BALL, BALL&> CBallArray;

//////////////////////////////////////////////////////////////////////////
class CGameClientEngine;
//游戏视图
class CGameClientView : public CGameFrameViewGDI
{
	int								m_iSavedWidth,m_iSavedHeight;
	//标志变量
protected:
	bool							m_bOutCard;							//出牌标志
	bool							m_bWaitOther;						//等待标志
	bool							m_bHuangZhuang;						//荒庄标志
	bool							m_bListenStatus[GAME_PLAYER];		//听牌标志
	bool							m_bTrustee[GAME_PLAYER];			//是否托管

	TCHAR                           m_szCenterText[MAX_PATH];           // 中心文字显示

	INT								m_nXFace;
	INT								m_nYFace;
	INT								m_nXTimer;
	INT								m_nYTimer;
	INT								m_nXBorder;
	INT								m_nYBorder;

	//游戏属性
protected:
	WORD							m_wBankerUser;						//庄家用户
	WORD							m_wCurrentUser;						//当前用户

	__int64                         m_lBaseScore;                       // 底分
public:
	BYTE							m_bBankerCount;
	bool							m_bTipSingle;

	//动作动画
protected:
	bool							m_bBombEffect;						//动作效果
	BYTE							m_cbBombFrameIndex;					//帧数索引

	//丢弃效果
	WORD							m_wDiscUser;						//丢弃用户
	BYTE							m_cbDiscFrameIndex;					//帧数索引
	BYTE                            m_byGodsData;                       // 财神牌

	//用户状态
protected:
	BYTE							m_cbCardData;						//出牌扑克
	WORD							m_wOutCardUser;						//出牌用户
	BYTE							m_cbUserAction[GAME_PLAYER];					//用户动作
	BYTE                            m_byDingMai[GAME_PLAYER];           // 顶买结果

	//位置变量
protected:
	CPoint							m_UserFlagPos[GAME_PLAYER];			//标志位置
	CPoint							m_UserListenPos[GAME_PLAYER];		//标志位置
	CPoint							m_PointTrustee[GAME_PLAYER];		//托管位置
	CPoint							m_ptDingMai[GAME_PLAYER];			//标志位置

	//位图变量
protected:
	CBitImage						m_ImageBack;						//背景图案
	CBitImage						m_ImageCenter;						//LOGO图
	CBitImage						m_ImageWait;						//等待提示
	//CBitImage						m_ImageOutCard;						//出牌提示
	CBitImage						m_ImageUserFlag;					//用户标志
	CBitImage						m_ImageUserAction;					//用户动作
	CBitImage						m_ImageActionBack;					//动作背景
	CBitImage						m_ImageCS;							//CaiSheng
	CBitImage						m_ImageHuangZhuang;					//荒庄标志
	CBitImage						m_ImageListenStatusH;				//听牌标志
	CBitImage						m_ImageListenStatusV;				//听牌标志
	CPngImage						m_ImageTrustee;						//托管标志
	CBitImage						m_ImageTipSingle;

	CPngImage						m_ImageActionAni;					//吃牌动画资源
	//CPngImage						m_ImageDisc;						//丢弃效果
	CPngImage						m_ImageArrow;						//定时器箭头
	CBitImage						m_ImageDingMai;						// 顶买
	CBitImage						m_ImageDingMaiFrame;				// 顶买框
	CBitImage						m_ImageNumber;				        // 数字
	CBitImage						ImageTimeBack;
	CBitImage						ImageTimeNumber;
	CBitImage						m_ImageReady;


	//扑克控件
public:
	CHeapCard						m_HeapCard[4];									//堆立扑克
	CUserCard						m_UserCard[GAME_PLAYER];						//用户扑克
	CTableCard						m_TableCard[GAME_PLAYER];						//桌面扑克
	CWeaveCard						m_WeaveCard[GAME_PLAYER][MAX_WEAVE];			//组合扑克
	CDiscardCard					m_DiscardCard[GAME_PLAYER];					    //丢弃扑克
	CCardControl					m_HandCardControl;					//手上扑克		

	int                             m_iSicboAnimIndex;                  // 骰子动画当前帧
	CBitImage						m_ImageSaizi;						// 图片资源

	CBallArray                      m_arBall;
	BYTE                            m_bySicbo[2];
	CPoint                          m_SicboAnimPoint;

	//控件变量
public:
	CSkinButton						m_btStart;							//开始按钮
	CSkinButton						m_btStusteeControl;					//拖管控制
	CControlWnd						m_ControlWnd;						//控制窗口
	CScoreControl					m_ScoreControl;						//积分控件
	CSkinButton						m_btMaiDi;							//买底
	CSkinButton						m_btDingDi;							//顶底
	CSkinButton						m_btMaiCancel;						//买底取消
	CSkinButton						m_btDingCancel;
	//视频组件
private:
	//CVideoServiceControl 			m_DlgVedioService[4];				//视频窗口
	CGameClientEngine					*m_pGameClientDlg;					//父类指针

	//函数定义
public:
	//构造函数
	CGameClientView();
	//析构函数
	virtual ~CGameClientView();

	//继承函数
private:
	//重置界面
	virtual VOID ResetGameView();
	//调整控件
	virtual VOID RectifyControl(INT nWidth, INT nHeight);
	//绘画界面
	virtual VOID DrawGameView(CDC * pDC, INT nWidth, INT nHeight);
	void DrawUserTimerEx(CDC * pDC, int nXPos, int nYPos, WORD wTime);
	virtual bool RealizeWIN7() { return true; }

	//功能函数
public:
	//基础积分
	void SetBaseScore(__int64 lBaseScore);
	//庄家用户
	void SetBankerUser(WORD wBankerUser);
	//荒庄设置
	void SetHuangZhuang(bool bHuangZhuang);
	//状态标志
	void SetStatusFlag(bool bOutCard, bool bWaitOther);
	//出牌信息
	void SetOutCardInfo(WORD wViewChairID, BYTE cbCardData);
	//动作信息
	void SetUserAction(WORD wViewChairID, BYTE bUserAction);
	//听牌标志
	void SetUserListenStatus(WORD wViewChairID, bool bListenStatus);
	//设置动作
	bool SetBombEffect(bool bBombEffect);
	//丢弃用户
	void SetDiscUser(WORD wDiscUser);
	//定时玩家
	void SetCurrentUser(WORD wCurrentUser);
	//设置托管
	void SetTrustee(WORD wTrusteeUser,bool bTrustee);
	// 设置中心文字
	void SetCenterText(LPCTSTR szText);
	void SetGodsCard(BYTE byGodsCard);
	BYTE GetGodsCard();
	void SetDingMaiValue(BYTE byDingMai[]);

	// 启动投骰子动画
	void StartSicboAnim(BYTE bySicbo[],int iStartIndex=0);

	void StopSicboAnim(void);
	//更新视图
	void RefreshGameView();
	//辅助函数
protected:
	//艺术字体
	void DrawTextString(CDC * pDC, LPCTSTR pszString, COLORREF crText, COLORREF crFrame, int nXPos, int nYPos);

	void DrawSicboAnim(CDC *pDC);

	void DrawNumberString(CDC * pDC, __int64 lNumber, INT nXPos, INT nYPos, bool bMeScore=false);

	//碰撞函数，根据两球碰撞方向和自身运动方向合成新的增量值 
	void mc12(BALL &mc1, BALL& mc2);
	//碰撞侦测 
	bool myHitTest(BALL &mc1, BALL& mc2);
	//碰撞函数
	void mcFanTang(BALL &mc);

	// 范围内运动
	void OnEnterRgn(double dbR);
	

	//消息映射
protected:
	//开始按钮
	afx_msg void OnStart();
	//拖管控制
	afx_msg void OnStusteeControl();
	//买底
	afx_msg void OnMaiDi();
	afx_msg void OnDingDi();
	afx_msg void OnMaiCancel();

	//建立函数
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//鼠标消息
	afx_msg void OnLButtonDown(UINT nFlags, CPoint Point);
	//光标消息
	afx_msg BOOL OnSetCursor(CWnd * pWnd, UINT nHitTest, UINT uMessage);

	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	virtual BOOL PreTranslateMessage(MSG* pMsg);
};

//////////////////////////////////////////////////////////////////////////

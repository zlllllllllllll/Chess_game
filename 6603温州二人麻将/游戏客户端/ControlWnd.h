#ifndef CONTROL_WND_HEAD_FILE
#define CONTROL_WND_HEAD_FILE

#pragma once

#include "Stdafx.h"
#include "Resource.h"
#include "..\消息定义\GameLogic.h"
#include "CardControl.h"

//////////////////////////////////////////////////////////////////////////

//消息定义
#define IDM_LISTEN_CARD				(WM_USER+300)						//扑克操作
#define IDM_CARD_OPERATE			(WM_USER+301)						//扑克操作

//////////////////////////////////////////////////////////////////////////

//控制窗口
class CControlWnd : public CWnd
{
	//配置变量
protected:
	BYTE							m_cbActionMask;						//类型掩码
	BYTE							m_cbCenterCard;						//中心扑克
	BYTE							m_cbGangCard[5];					//杠牌数据
	CPoint							m_PointBenchmark;					//基准位置
	CWnd *							m_pSinkWindow;						//回调窗口
	//状态变量
protected:
	BYTE							m_cbItemCount;						//子项数目
	BYTE							m_cbCurrentItem;					//当前子项

	//控件变量
protected:
	CSkinButton						m_btChiHu;							//吃胡按钮
//	CSkinButton						m_btListen;							//听牌按钮
	CSkinButton						m_btGiveUp;							//放弃按钮
	CSkinButton						m_btChiShang;
	CSkinButton						m_btChiZhong;
	CSkinButton						m_btChiXia;
	CSkinButton						m_btPeng;
	CSkinButton						m_btGang;

	//资源变量
protected:
    CBitImage						m_ImageControlTop;					//资源图片
    CBitImage						m_ImageControlMid;					//资源图片
    CBitImage						m_ImageControlButtom;				//资源图片
	CBitImage						m_ImageActionExplain;				//动作解释

	//函数定义
public:
	//构造函数
	CControlWnd();
	//析构函数
	virtual ~CControlWnd();

	//控件控制
public:
	//基准位置
	void SetBenchmarkPos(int nXPos, int nYPos);
	//设置扑克
	void SetControlInfo(BYTE cbCenterCard, BYTE cbActionMask, tagGangCardResult & GangCardResult);
	//设置窗口
	void SetSinkWindow(CWnd * pSinkWindow);
	//内部函数
protected:
	//调整控件
	void RectifyControl();

	//消息映射
protected:
	//重画函数
	afx_msg void OnPaint();
	//吃胡按钮
	afx_msg void OnChiHu();
	//听牌按钮
	afx_msg void OnListen();
	afx_msg void OnChiShang();
	afx_msg	void OnChiZhong();
	afx_msg	void OnChiXia();
	afx_msg	void OnPeng();
	afx_msg	void OnGang();
	//放弃按钮
	afx_msg void OnGiveUp();
	//建立消息
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//鼠标消息
	afx_msg void OnLButtonDown(UINT nFlags, CPoint Point);
	//光标消息
	afx_msg BOOL OnSetCursor(CWnd * pWnd, UINT nHitTest, UINT uMessage);

	DECLARE_MESSAGE_MAP()
public:
	afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
	HRGN BitmapToRegion(HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance=NULL);
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	CCardControl	*m_cardControl;
};

//////////////////////////////////////////////////////////////////////////

#endif
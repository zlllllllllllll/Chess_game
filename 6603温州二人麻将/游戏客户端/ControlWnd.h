#ifndef CONTROL_WND_HEAD_FILE
#define CONTROL_WND_HEAD_FILE

#pragma once

#include "Stdafx.h"
#include "Resource.h"
#include "..\��Ϣ����\GameLogic.h"
#include "CardControl.h"

//////////////////////////////////////////////////////////////////////////

//��Ϣ����
#define IDM_LISTEN_CARD				(WM_USER+300)						//�˿˲���
#define IDM_CARD_OPERATE			(WM_USER+301)						//�˿˲���

//////////////////////////////////////////////////////////////////////////

//���ƴ���
class CControlWnd : public CWnd
{
	//���ñ���
protected:
	BYTE							m_cbActionMask;						//��������
	BYTE							m_cbCenterCard;						//�����˿�
	BYTE							m_cbGangCard[5];					//��������
	CPoint							m_PointBenchmark;					//��׼λ��
	CWnd *							m_pSinkWindow;						//�ص�����
	//״̬����
protected:
	BYTE							m_cbItemCount;						//������Ŀ
	BYTE							m_cbCurrentItem;					//��ǰ����

	//�ؼ�����
protected:
	CSkinButton						m_btChiHu;							//�Ժ���ť
//	CSkinButton						m_btListen;							//���ư�ť
	CSkinButton						m_btGiveUp;							//������ť
	CSkinButton						m_btChiShang;
	CSkinButton						m_btChiZhong;
	CSkinButton						m_btChiXia;
	CSkinButton						m_btPeng;
	CSkinButton						m_btGang;

	//��Դ����
protected:
    CBitImage						m_ImageControlTop;					//��ԴͼƬ
    CBitImage						m_ImageControlMid;					//��ԴͼƬ
    CBitImage						m_ImageControlButtom;				//��ԴͼƬ
	CBitImage						m_ImageActionExplain;				//��������

	//��������
public:
	//���캯��
	CControlWnd();
	//��������
	virtual ~CControlWnd();

	//�ؼ�����
public:
	//��׼λ��
	void SetBenchmarkPos(int nXPos, int nYPos);
	//�����˿�
	void SetControlInfo(BYTE cbCenterCard, BYTE cbActionMask, tagGangCardResult & GangCardResult);
	//���ô���
	void SetSinkWindow(CWnd * pSinkWindow);
	//�ڲ�����
protected:
	//�����ؼ�
	void RectifyControl();

	//��Ϣӳ��
protected:
	//�ػ�����
	afx_msg void OnPaint();
	//�Ժ���ť
	afx_msg void OnChiHu();
	//���ư�ť
	afx_msg void OnListen();
	afx_msg void OnChiShang();
	afx_msg	void OnChiZhong();
	afx_msg	void OnChiXia();
	afx_msg	void OnPeng();
	afx_msg	void OnGang();
	//������ť
	afx_msg void OnGiveUp();
	//������Ϣ
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//�����Ϣ
	afx_msg void OnLButtonDown(UINT nFlags, CPoint Point);
	//�����Ϣ
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
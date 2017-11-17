#pragma once

#include "CardControl.h"

// CCardExtractor �Ի���

class CCardExtractor : public CDialog
{
	DECLARE_DYNAMIC(CCardExtractor)

public:
	CCardExtractor(CWnd* pParent = NULL);   // ��׼���캯��
	virtual ~CCardExtractor();
PVOID   m_pClientDlg;
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV ֧��

	DECLARE_MESSAGE_MAP()

protected:
	CCardControl  m_CardCtrl[4];
	BYTE		  m_cbHoverCard;
public:
	afx_msg void OnPaint();
public:
	virtual BOOL OnInitDialog();
	virtual void OnOK();
public:
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
public:
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
};

#pragma once

#include "Stdafx.h"
#include "ControlWnd.h"
#include "CardControl.h"
#include "ScoreControl.h"

//////////////////////////////////////////////////////////////////////////
//��Ϣ����

#define IDM_START					(WM_USER+100)						//��ʼ��Ϣ
#define IDM_OUT_CARD				(WM_USER+101)						//������Ϣ
#define IDM_TRUSTEE_CONTROL			(WM_USER+102)						//�йܿ���
#define IDM_DING_DI			        (WM_USER+103)						// ��ף�����
#define IDM_DISPATCH_CARD           (WM_USER + 104)                    // ��ҷ���
#define IDM_OUT_INVALID_CARD		(WM_USER+105)

#define IDI_DISC_EFFECT					102								//����Ч��

typedef struct tagBall
{
	double dbX;      // x����
	double dbY;      // y����
	double dbWidth;  // ���
	double dbHeight; // �߶�
	double dbDx;     // x����
	double dbDy;     // y����
	int iIndex;      // ����
}BALL;
typedef CArray<BALL, BALL&> CBallArray;

//////////////////////////////////////////////////////////////////////////
class CGameClientEngine;
//��Ϸ��ͼ
class CGameClientView : public CGameFrameViewGDI
{
	int								m_iSavedWidth,m_iSavedHeight;
	//��־����
protected:
	bool							m_bOutCard;							//���Ʊ�־
	bool							m_bWaitOther;						//�ȴ���־
	bool							m_bHuangZhuang;						//��ׯ��־
	bool							m_bListenStatus[GAME_PLAYER];		//���Ʊ�־
	bool							m_bTrustee[GAME_PLAYER];			//�Ƿ��й�

	TCHAR                           m_szCenterText[MAX_PATH];           // ����������ʾ

	INT								m_nXFace;
	INT								m_nYFace;
	INT								m_nXTimer;
	INT								m_nYTimer;
	INT								m_nXBorder;
	INT								m_nYBorder;

	//��Ϸ����
protected:
	WORD							m_wBankerUser;						//ׯ���û�
	WORD							m_wCurrentUser;						//��ǰ�û�

	__int64                         m_lBaseScore;                       // �׷�
public:
	BYTE							m_bBankerCount;
	bool							m_bTipSingle;

	//��������
protected:
	bool							m_bBombEffect;						//����Ч��
	BYTE							m_cbBombFrameIndex;					//֡������

	//����Ч��
	WORD							m_wDiscUser;						//�����û�
	BYTE							m_cbDiscFrameIndex;					//֡������
	BYTE                            m_byGodsData;                       // ������

	//�û�״̬
protected:
	BYTE							m_cbCardData;						//�����˿�
	WORD							m_wOutCardUser;						//�����û�
	BYTE							m_cbUserAction[GAME_PLAYER];					//�û�����
	BYTE                            m_byDingMai[GAME_PLAYER];           // ������

	//λ�ñ���
protected:
	CPoint							m_UserFlagPos[GAME_PLAYER];			//��־λ��
	CPoint							m_UserListenPos[GAME_PLAYER];		//��־λ��
	CPoint							m_PointTrustee[GAME_PLAYER];		//�й�λ��
	CPoint							m_ptDingMai[GAME_PLAYER];			//��־λ��

	//λͼ����
protected:
	CBitImage						m_ImageBack;						//����ͼ��
	CBitImage						m_ImageCenter;						//LOGOͼ
	CBitImage						m_ImageWait;						//�ȴ���ʾ
	//CBitImage						m_ImageOutCard;						//������ʾ
	CBitImage						m_ImageUserFlag;					//�û���־
	CBitImage						m_ImageUserAction;					//�û�����
	CBitImage						m_ImageActionBack;					//��������
	CBitImage						m_ImageCS;							//CaiSheng
	CBitImage						m_ImageHuangZhuang;					//��ׯ��־
	CBitImage						m_ImageListenStatusH;				//���Ʊ�־
	CBitImage						m_ImageListenStatusV;				//���Ʊ�־
	CPngImage						m_ImageTrustee;						//�йܱ�־
	CBitImage						m_ImageTipSingle;

	CPngImage						m_ImageActionAni;					//���ƶ�����Դ
	//CPngImage						m_ImageDisc;						//����Ч��
	CPngImage						m_ImageArrow;						//��ʱ����ͷ
	CBitImage						m_ImageDingMai;						// ����
	CBitImage						m_ImageDingMaiFrame;				// �����
	CBitImage						m_ImageNumber;				        // ����
	CBitImage						ImageTimeBack;
	CBitImage						ImageTimeNumber;
	CBitImage						m_ImageReady;


	//�˿˿ؼ�
public:
	CHeapCard						m_HeapCard[4];									//�����˿�
	CUserCard						m_UserCard[GAME_PLAYER];						//�û��˿�
	CTableCard						m_TableCard[GAME_PLAYER];						//�����˿�
	CWeaveCard						m_WeaveCard[GAME_PLAYER][MAX_WEAVE];			//����˿�
	CDiscardCard					m_DiscardCard[GAME_PLAYER];					    //�����˿�
	CCardControl					m_HandCardControl;					//�����˿�		

	int                             m_iSicboAnimIndex;                  // ���Ӷ�����ǰ֡
	CBitImage						m_ImageSaizi;						// ͼƬ��Դ

	CBallArray                      m_arBall;
	BYTE                            m_bySicbo[2];
	CPoint                          m_SicboAnimPoint;

	//�ؼ�����
public:
	CSkinButton						m_btStart;							//��ʼ��ť
	CSkinButton						m_btStusteeControl;					//�Ϲܿ���
	CControlWnd						m_ControlWnd;						//���ƴ���
	CScoreControl					m_ScoreControl;						//���ֿؼ�
	CSkinButton						m_btMaiDi;							//���
	CSkinButton						m_btDingDi;							//����
	CSkinButton						m_btMaiCancel;						//���ȡ��
	CSkinButton						m_btDingCancel;
	//��Ƶ���
private:
	//CVideoServiceControl 			m_DlgVedioService[4];				//��Ƶ����
	CGameClientEngine					*m_pGameClientDlg;					//����ָ��

	//��������
public:
	//���캯��
	CGameClientView();
	//��������
	virtual ~CGameClientView();

	//�̳к���
private:
	//���ý���
	virtual VOID ResetGameView();
	//�����ؼ�
	virtual VOID RectifyControl(INT nWidth, INT nHeight);
	//�滭����
	virtual VOID DrawGameView(CDC * pDC, INT nWidth, INT nHeight);
	void DrawUserTimerEx(CDC * pDC, int nXPos, int nYPos, WORD wTime);
	virtual bool RealizeWIN7() { return true; }

	//���ܺ���
public:
	//��������
	void SetBaseScore(__int64 lBaseScore);
	//ׯ���û�
	void SetBankerUser(WORD wBankerUser);
	//��ׯ����
	void SetHuangZhuang(bool bHuangZhuang);
	//״̬��־
	void SetStatusFlag(bool bOutCard, bool bWaitOther);
	//������Ϣ
	void SetOutCardInfo(WORD wViewChairID, BYTE cbCardData);
	//������Ϣ
	void SetUserAction(WORD wViewChairID, BYTE bUserAction);
	//���Ʊ�־
	void SetUserListenStatus(WORD wViewChairID, bool bListenStatus);
	//���ö���
	bool SetBombEffect(bool bBombEffect);
	//�����û�
	void SetDiscUser(WORD wDiscUser);
	//��ʱ���
	void SetCurrentUser(WORD wCurrentUser);
	//�����й�
	void SetTrustee(WORD wTrusteeUser,bool bTrustee);
	// ������������
	void SetCenterText(LPCTSTR szText);
	void SetGodsCard(BYTE byGodsCard);
	BYTE GetGodsCard();
	void SetDingMaiValue(BYTE byDingMai[]);

	// ����Ͷ���Ӷ���
	void StartSicboAnim(BYTE bySicbo[],int iStartIndex=0);

	void StopSicboAnim(void);
	//������ͼ
	void RefreshGameView();
	//��������
protected:
	//��������
	void DrawTextString(CDC * pDC, LPCTSTR pszString, COLORREF crText, COLORREF crFrame, int nXPos, int nYPos);

	void DrawSicboAnim(CDC *pDC);

	void DrawNumberString(CDC * pDC, __int64 lNumber, INT nXPos, INT nYPos, bool bMeScore=false);

	//��ײ����������������ײ����������˶�����ϳ��µ�����ֵ 
	void mc12(BALL &mc1, BALL& mc2);
	//��ײ��� 
	bool myHitTest(BALL &mc1, BALL& mc2);
	//��ײ����
	void mcFanTang(BALL &mc);

	// ��Χ���˶�
	void OnEnterRgn(double dbR);
	

	//��Ϣӳ��
protected:
	//��ʼ��ť
	afx_msg void OnStart();
	//�Ϲܿ���
	afx_msg void OnStusteeControl();
	//���
	afx_msg void OnMaiDi();
	afx_msg void OnDingDi();
	afx_msg void OnMaiCancel();

	//��������
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//�����Ϣ
	afx_msg void OnLButtonDown(UINT nFlags, CPoint Point);
	//�����Ϣ
	afx_msg BOOL OnSetCursor(CWnd * pWnd, UINT nHitTest, UINT uMessage);

	DECLARE_MESSAGE_MAP()

public:
	afx_msg void OnTimer(UINT nIDEvent);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	virtual BOOL PreTranslateMessage(MSG* pMsg);
};

//////////////////////////////////////////////////////////////////////////

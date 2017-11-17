#ifndef SCORE_CONTROL_HEAD_FILE
#define SCORE_CONTROL_HEAD_FILE

#pragma once

#include "Stdafx.h"
#include "CardControl.h"

//////////////////////////////////////////////////////////////////////////

//������Ϣ
struct tagScoreInfo
{
	//�����˿�
	BYTE							cbCardCount;							//�˿���Ŀ
	BYTE							cbCardData[MAX_COUNT];					//�˿�����

	//�û���Ϣ
	WORD							wBankerUser;							//ׯ���û�
	TCHAR							szUserName[GAME_PLAYER][NAME_LEN];		//�û�����

	//������Ϣ
	WORD							wProvideUser;							//��Ӧ�û�
	BYTE							cbProvideCard;							//��Ӧ�˿�
	__int64							lGameScore[GAME_PLAYER];				//��Ϸ����
	__int64							lGodsScore[GAME_PLAYER];				//�����
	BYTE                            byDingDi[GAME_PLAYER];                  // ���׽��

	//���ƽ��
	DWORD							dwChiHuKind[GAME_PLAYER];				//��������
	DWORD							dwChiHuRight[GAME_PLAYER];				//��������
};

//�����Ϣ
struct tagWeaveInfo
{
	BYTE							cbWeaveCount;							// �����Ŀ
	BYTE							cbCardCount[MAX_WEAVE];					// �˿���Ŀ(ÿ���Ƶ���Ŀ)
	BYTE							cbPublicWeave[MAX_WEAVE];				// �������
	BYTE							cbCardData[MAX_WEAVE][4];				// ����˿�(ÿ���Ƶ���ֵ)
};

//////////////////////////////////////////////////////////////////////////

//���ֿؼ�
class CScoreControl : public CWnd
{
	//��������
protected:
	tagScoreInfo					m_ScoreInfo;							//������Ϣ

	//�ؼ�����
protected:
	BYTE							m_cbWeaveCount;							//�����Ŀ
	CWeaveCard						m_WeaveCard[MAX_WEAVE];					//����˿�
	CSkinButton						m_btCloseScore;							//�رհ�ť
	WORD							m_dwMeUserID;

	//��Դ����
protected:
	CBitImage						m_ImageWin;							//ʤ
	CBitImage						m_ImageDraw;						//���֣�����������ʾ
	CImage							m_ImageGameScore;						//������ͼ
	CBitImage						m_ImageGameScoreFlag;					//������ͼ

	//��������
public:
	//���캯��
	CScoreControl();
	//��������
	virtual ~CScoreControl();

	//���ܺ���
public:
	//��λ����
	void RestorationData();
	//���û���
	void SetScoreInfo(const tagScoreInfo & ScoreInfo, const tagWeaveInfo & WeaveInfo,WORD dwMeUserID);
	int GetHardSoftHu();
	HRGN BitmapToRegion(HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance=NULL);
	//��ť��Ϣ
protected:
	//�رհ�ť
	afx_msg void OnBnClickedClose();

	//��Ϣӳ��
protected:
	//�ػ�����
	afx_msg void OnPaint();
	//�滭����
	afx_msg BOOL OnEraseBkgnd(CDC * pDC);
	//��������
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	//�����Ϣ
	afx_msg void OnLButtonDown(UINT nFlags, CPoint Point);

	DECLARE_MESSAGE_MAP()
public:
	afx_msg void OnMove(int x, int y);
};

//////////////////////////////////////////////////////////////////////////

#endif
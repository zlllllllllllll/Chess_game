#pragma once

#include "Stdafx.h"
#include "..\��Ϣ����\GameLogic.h"
#include "GameClientView.h"

//////////////////////////////////////////////////////////////////////////

//��Ϸ�Ի���
class CGameClientEngine : public CGameFrameEngine
{
	//��Ԫ����
	friend class CGameClientView;
	//�û�����
protected:
	WORD							m_wBankerUser;						//ׯ���û�
	WORD							m_wCurrentUser;						//��ǰ�û�

	bool							m_bChineseVoice;

		BYTE							m_cbUserAction;						//��Ҷ���
	
	//״̬����
protected:
	bool							m_bHearStatus;						//����״̬
	bool							m_bWillHearStatus;					//��������

	//�йܱ���
protected:
	bool							m_bStustee;							//�йܱ�־
	WORD							m_wTimeOutCount;					//��ʱ����

	//��������
protected:
	WORD							m_wHeapHand;						//����ͷ��
	WORD							m_wHeapTail;						//����β��
	BYTE							m_cbHeapCardInfo[4][2];				//������Ϣ

	//�˿˱���
protected:
	BYTE							m_cbLeftCardCount;					//ʣ����Ŀ
	BYTE							m_cbCardIndex[MAX_INDEX];			//�����˿�

	//����˿�
protected:
	BYTE							m_cbWeaveCount[GAME_PLAYER];		//�����Ŀ
	tagWeaveItem					m_WeaveItemArray[GAME_PLAYER][MAX_WEAVE];	//����˿�

	//������Ϣ
protected:
	WORD							m_wOutCardUser;						//�����û�
	BYTE							m_cbOutCardData;					//�����˿�
	BYTE							m_cbDiscardCount[GAME_PLAYER];		//������Ŀ
	BYTE							m_cbDiscardCard[GAME_PLAYER][55];	//������¼
	BYTE                            m_bySicboAnimCount;


	//�ؼ�����
protected:
	CGameLogic                      m_GameLogic;						//��Ϸ�߼�
	CGameClientView					m_GameClientView;					//��Ϸ��ͼ
	const tagServerAttribute		*pServerAttribute ;

	CMD_S_GamePlay   m_sGamePlay;  // ��Ϸ������Ϣ
	
	//��������
public:
	//���캯��
	CGameClientEngine();
	//��������
	virtual ~CGameClientEngine();

	//����̳�
public:
	//��������
	virtual bool OnInitGameEngine();
	//���ú���
	virtual bool OnResetGameEngine();
	//��Ϸ����
	virtual void OnGameOptionSet();
public:
	virtual bool OnEventGameClockKill(WORD wChairID);
	//ʱ����Ϣ
	virtual bool OnEventGameClockInfo(WORD wChairID, UINT nElapse, WORD wClockID);

	//��Ϸ�¼�
public:
	//�Թ���Ϣ
	virtual bool OnEventLookonMode(VOID * pData, WORD wDataSize);
	//��Ϸ��Ϣ
	virtual bool OnEventGameMessage(WORD wSubCmdID, VOID * pData, WORD wDataSize);
	//������Ϣ
	virtual bool OnEventSceneMessage(BYTE cbGameStatus, bool bLookonUser, VOID * pData, WORD wDataSize);
	virtual void OnLookonViewChange(bool bLookon);
	//��Ϣ����
protected:
	//��Ϸ��ʼ
	bool OnSubGameStart(const void * pBuffer, WORD wDataSize);
	//�û�����
	bool OnSubListenCard(const void * pBuffer, WORD wDataSize);
	//�û�����
	bool OnSubOutCard(const void * pBuffer, WORD wDataSize);
	//������Ϣ
	bool OnSubSendCard(const void * pBuffer, WORD wDataSize);
	//������ʾ
	bool OnSubOperateNotify(const void * pBuffer, WORD wDataSize);
	//�������
	bool OnSubOperateResult(const void * pBuffer, WORD wDataSize);
	//��Ϸ����
	bool OnSubGameEnd(const void * pBuffer, WORD wDataSize);
	//�û��й�
	bool OnSubTrustee(const void * pBuffer,WORD wDataSize);
	// ׯ�����
	bool OnSubDingDi(const void * pBuffer,WORD wDataSize);
	bool OnSubGamePlay(const void * pBuffer,WORD wDataSize);
	//��������
protected:
	//��������
	void PlayCardSound(WORD wChairID,BYTE cbCardData);
	//��������
	void PlayActionSound(WORD wChairID,BYTE cbAction);
	//�����ж�
	bool VerdictOutCard(BYTE cbCardData);
	//�۳��˿�
	void DeductionTableCard(bool bHeadCard);
	//��ʾ����
	bool ShowOperateControl(BYTE cbUserAction, BYTE cbActionCard);

	//��Ϣӳ��
protected:
	//��ʼ��Ϣ
	LRESULT OnStart(WPARAM wParam, LPARAM lParam);
	//���Ʋ���
	LRESULT OnOutCard(WPARAM wParam, LPARAM lParam);
	LRESULT OnOutInvalidCard(WPARAM wParam,LPARAM lParam);
	//���Ʋ���
	LRESULT OnListenCard(WPARAM wParam, LPARAM lParam);
	//�˿˲���
	LRESULT OnCardOperate(WPARAM wParam, LPARAM lParam);
	//�Ϲܿ���
	LRESULT OnStusteeControl(WPARAM wParam, LPARAM lParam);
	LRESULT OnDingDi(WPARAM wParam, LPARAM lParam);
	LRESULT OnDispatchCard(WPARAM wParam, LPARAM lParam);
	WORD SwitchHeapViewChairID(WORD wChairID);

	DECLARE_MESSAGE_MAP()
public:
	bool IsFreeze(void);
};

//////////////////////////////////////////////////////////////////////////

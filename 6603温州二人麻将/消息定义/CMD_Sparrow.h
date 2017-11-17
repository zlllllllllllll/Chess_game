#ifndef CMD_SPARROW_HEAD_FILE
#define CMD_SPARROW_HEAD_FILE

//////////////////////////////////////////////////////////////////////////
//�����궨��

#define KIND_ID						306								//��Ϸ I D
#define GAME_PLAYER					2									//��Ϸ����
#define GAME_NAME					TEXT("��ͳ�����齫")					//��Ϸ����
#define GAME_GENRE					(GAME_GENRE_SCORE|GAME_GENRE_MATCH|GAME_GENRE_GOLD)	//��Ϸ����

#define VERSION_SERVER			    	PROCESS_VERSION(6,0,3)				//����汾
#define VERSION_CLIENT				    PROCESS_VERSION(6,0,3)				//����汾

#define NAME_LEN					32
//////////////////////////////////////////////////////////////////////////
//��Ϸ״̬
#define GS_MJ_FREE					GAME_STATUS_FREE								// ����״̬
#define GS_MJ_MAIDI				    (GAME_STATUS_PLAY+1)						// ��ׯ״̬
#define GS_MJ_PLAY				   GAME_STATUS_PLAY						// ��Ϸ״̬

//��������
#define MAX_WEAVE					5									//������
#define MAX_INDEX					34									//�������
#define MAX_COUNT					17									//�����Ŀ
#define MAX_REPERTORY				136									//�����

#define GAME_SCENE_FREE				GAME_STATUS_FREE					//�ȴ���ʼ
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

//�������
struct CMD_WeaveItem
{
	BYTE							cbWeaveKind;						//�������
	BYTE							cbCenterCard;						//�����˿�
	BYTE							cbPublicCard;						//������־
	WORD							wProvideUser;						//��Ӧ�û�
};

//////////////////////////////////////////////////////////////////////////
//����������ṹ

#define SUB_S_GAME_START			100									//��Ϸ��ʼ
#define SUB_S_OUT_CARD				101									//��������
#define SUB_S_SEND_CARD				102									//�����˿�
#define SUB_S_LISTEN_CARD			103									//��������
#define SUB_S_OPERATE_NOTIFY		104									//������ʾ
#define SUB_S_OPERATE_RESULT		105									//��������
#define SUB_S_GAME_END				106									//��Ϸ����
#define SUB_S_TRUSTEE				107									//�û��й�
#define SUB_S_DINGDI				108									// ��Ҷ���
#define SUB_S_GAME_PLAY				109									// ��Ϸ��ʽ��ʼ

//��Ϸ״̬
struct CMD_S_StatusFree
{
	__int64							lCellScore;							//�������
	WORD							wBankerUser;						//ׯ���û�
	bool							bTrustee[GAME_PLAYER];						//�Ƿ��й�
	TCHAR							szRoomName[32];
};

struct CMD_S_StatusMaiDi
{
	__int64							lCellScore;							//�������
	__int64                         lBaseScore;                         // �׷�
	WORD							wBankerUser;						//ׯ���û�
	bool							bTrustee[GAME_PLAYER];				// �Ƿ��й�
	bool                            bBankerMaiDi;                       // ׯ���Ƿ���Ҫ���
	bool                            bMeDingDi;                          // �Լ��Ƿ���Ҫ����
	TCHAR							szRoomName[32];
};

//��Ϸ״̬
struct CMD_S_StatusPlay
{
	//��Ϸ����
	__int64							lCellScore;									// ��Ԫ����
	WORD							wSiceCount1;								// ���ӵ���
	WORD							wSiceCount2;								// ���ӵ���
	WORD							wSiceCount3;								// ���ӵ���

	WORD							wBankerUser;								//ׯ���û�
	WORD							wCurrentUser;								//��ǰ�û�

	//״̬����
	BYTE							cbActionCard;								//�����˿�
	BYTE							cbActionMask;								//��������
	BYTE							cbHearStatus[GAME_PLAYER];					//����״̬
	BYTE							cbLeftCardCount;							//ʣ����Ŀ
	bool							bTrustee[GAME_PLAYER];						//�Ƿ��й�

	//������Ϣ
	WORD							wOutCardUser;								//�����û�
	BYTE							cbOutCardData;								//�����˿�
	BYTE							cbDiscardCount[GAME_PLAYER];				//������Ŀ
	BYTE							cbDiscardCard[GAME_PLAYER][60];				//������¼
	BYTE							byDingDi[GAME_PLAYER];						//���׽��
	BYTE                            byOutCardIndex[MAX_INDEX];                  // �Ѿ��������

	//�˿�����
	BYTE							cbCardCount;								//�˿���Ŀ
	BYTE							cbCardData[MAX_COUNT];						//�˿��б�
	BYTE							cbSendCardData;								//�����˿�
	BYTE                            byGodsCardData;

	//����˿�
	BYTE							cbWeaveCount[GAME_PLAYER];					//�����Ŀ
	CMD_WeaveItem					WeaveItemArray[GAME_PLAYER][MAX_WEAVE];		//����˿�
	TCHAR							szRoomName[32];
};

//��Ϸ��ʼ
struct CMD_S_GameStart
{
	WORD							wBankerUser;								//ׯ���û�
	BYTE							bBankerCount;
	__int64							lBaseScore;									// �׷�
	bool                            bMaiDi;                                     // ׯ���Ƿ�������
	bool							bTrustee[GAME_PLAYER];						//�Ƿ��й�
};

struct CMD_S_GamePlay
{
	WORD							wSiceCount1;								// ���ӵ���
	WORD							wSiceCount2;								// ���ӵ���
	WORD							wSiceCount3;								// ���ӵ���
	WORD							wCurrentUser;								// ��ǰ�û�
	BYTE							cbUserAction;								// �û�����
	BYTE                            byGodsCardData;                             // ������
	BYTE                            byUserDingDi[GAME_PLAYER];                  // ��Ҷ������
	BYTE							cbCardData[GAME_PLAYER][MAX_COUNT];			// �˿��б�
};

//��������
struct CMD_S_OutCard
{
	WORD							wOutCardUser;						//�����û�
	BYTE							cbOutCardData;						//�����˿�
};

//�����˿�
struct CMD_S_SendCard
{
	BYTE							cbCardData;							//�˿�����
	BYTE							cbActionMask;						//��������
	WORD							wCurrentUser;						//��ǰ�û�
};

//��������
struct CMD_S_ListenCard
{
	WORD							wListenUser;						//�����û�
};

//������ʾ
struct CMD_S_OperateNotify
{
	WORD							wResumeUser;						//��ԭ�û�
	BYTE							cbActionMask;						//��������
	BYTE							cbActionCard;						//�����˿�
};

//��������
struct CMD_S_OperateResult
{
	WORD							wOperateUser;						//�����û�
	WORD							wProvideUser;						//��Ӧ�û�
	BYTE							cbOperateCode;						//��������
	BYTE							cbOperateCard;						//�����˿�
};

//��Ϸ����
struct CMD_S_GameEnd
{
	__int64							lGameTax;							//��Ϸ˰��
	//������Ϣ
	WORD							wProvideUser;						//��Ӧ�û�
	BYTE							cbProvideCard;						//��Ӧ�˿�
	DWORD							dwChiHuKind[GAME_PLAYER];			//��������
	DWORD							dwChiHuRight[GAME_PLAYER];			//��������
	BYTE                            byDingDi[GAME_PLAYER];

	//������Ϣ
	__int64						lGameScore[GAME_PLAYER];			//��Ϸ����
	__int64						lGodsScore[GAME_PLAYER];			//��Ϸ����

	//�˿���Ϣ
	BYTE							cbCardCount[GAME_PLAYER];			//�˿���Ŀ
	BYTE							cbCardData[GAME_PLAYER][MAX_COUNT];	//�˿�����
};
//�û��й�
struct CMD_S_Trustee
{
	bool							bTrustee;							//�Ƿ��й�
	WORD							wChairID;							//�й��û�
};

//�û��й�
struct CMD_S_DingDi
{
	BYTE							byMaiDi;							// ׯ����׽��
	WORD							wChairID;							// �����û�
	bool                            bDingDi;                            // �м��Ƿ���Զ���                 
};

//////////////////////////////////////////////////////////////////////////
//�ͻ�������ṹ

#define SUB_C_OUT_CARD				1									//��������
#define SUB_C_LISTEN_CARD			2									//��������
#define SUB_C_OPERATE_CARD			3									//�����˿�
#define SUB_C_TRUSTEE				4									//�û��й�
#define SUB_C_SET_CARD              5                                   // ȡ������
#define SUB_C_DINGDI                6                                   // ����
#define SUB_C_CHECK_SUPER			7

//��������
struct CMD_C_OutCard
{
	BYTE							cbCardData;							//�˿�����
};

//��������
struct CMD_C_OperateCard
{
	BYTE							cbOperateCode;						//��������
	BYTE							cbOperateCard;						//�����˿�
};
//�û��й�
struct CMD_C_Trustee
{
	bool							bTrustee;							//�Ƿ��й�	
};

struct CMD_C_DingDi
{
	BYTE 							byDingDi;							// �����Ƿ������ׯ�ұ�ʾ���	
};
//////////////////////////////////////////////////////////////////////////

#endif
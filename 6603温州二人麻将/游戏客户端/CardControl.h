#ifndef CARD_CONTROL_HEAD_FILE
#define CARD_CONTROL_HEAD_FILE

#pragma once

#include "Stdafx.h"
#include "Resource.h"
#include "..\��Ϣ����\GameLogic.h"
#include "cassert"
//////////////////////////////////////////////////////////////////////////
//	�˿˶���

//	0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,						//����
//	0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,						//����
//	0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,						//ͬ��
//	0x31,0x32,0x33,0x34,0x35,0x36,0x37,									//����
//	0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,							//����

//////////////////////////////////////////////////////////////////////////

//�˿˶���
#define HEAP_FULL_COUNT				34									//����ȫ��

//////////////////////////////////////////////////////////////////////////

//X ���з�ʽ
enum enXCollocateMode 
{ 
	enXLeft,						//�����
	enXCenter,						//�ж���
	enXRight,						//�Ҷ���
};

//Y ���з�ʽ
enum enYCollocateMode 
{ 
	enYTop,							//�϶���
	enYCenter,						//�ж���
	enYBottom,						//�¶���
};

//����ö��
enum enDirection
{
	Direction_East,					//����
	Direction_South,				//����
	Direction_West,					//����
	Direction_North,				//����
};

//////////////////////////////////////////////////////////////////////////

//�˿�ͼƬ
class CCardListImage
{
	//λ�ñ���
protected:
	int								m_nItemWidth;						//����߶�
	int								m_nItemHeight;						//������
	int								m_nViewWidth;						//����߶�
	int								m_nViewHeight;						//������

	//��Դ����
protected:
	CBitImage						m_CardListImage;					//ͼƬ��Դ
	CBitImage						m_csFlag;
	CBitImage						m_CardBack;
	//��������
public:
	//���캯��
	CCardListImage();
	//��������
	virtual ~CCardListImage();

	//��Ϣ����
public:
	//��ȡ���
	int GetViewWidth() { return m_nViewWidth; }
	//��ȡ�߶�
	int GetViewHeight() { return m_nViewHeight; }

	//��Դ����
public:
	//������Դ
	bool LoadResource(UINT uResourceID, int nViewWidth, int nViewHeight);
	//�ͷ���Դ
	bool DestroyResource();

	//���ܺ���
public:
	//��ȡλ��
	inline int GetImageIndex(BYTE cbCardData);
	//�滭�˿�
	inline bool DrawCardItem(CDC * pDestDC, BYTE cbCardData, int xDest, int yDest,BYTE cbGodsData=0,bool bDrawBack=false,int nItemWidth=0,int nItemHeight=0);
};

//////////////////////////////////////////////////////////////////////////

//�˿���Դ
class CCardResource
{
	//�û��˿�
public:
	CBitImage						m_ImageUserTop;						//ͼƬ��Դ
	CBitImage						m_ImageUserLeft;					//ͼƬ��Դ
	CBitImage						m_ImageUserRight;					//ͼƬ��Դ
	CCardListImage					m_ImageUserBottom;					//ͼƬ��Դ
	//CCardListImage					m_ImageUserDisable;					//ͼƬ��Դ

	//�����˿�
public:
	CCardListImage					m_ImageTableTop;					//ͼƬ��Դ
	CCardListImage					m_ImageTableLeft;					//ͼƬ��Դ
	CCardListImage					m_ImageTableRight;					//ͼƬ��Դ
	CCardListImage					m_ImageTableBottom;					//ͼƬ��Դ

	//CCardListImage					m_ImageWaveTop;
	CCardListImage					m_ImageWaveBottom;

	//�ƶ��˿�
public:
	CBitImage						m_ImageBackH;						//ͼƬ��Դ
	CBitImage						m_ImageBackV;						//ͼƬ��Դ
	CBitImage						m_ImageHeapSingleV;					//ͼƬ��Դ
	CBitImage						m_ImageHeapSingleH;					//ͼƬ��Դ
	CBitImage						m_ImageHeapDoubleV;					//ͼƬ��Դ
	CBitImage						m_ImageHeapDoubleH;					//ͼƬ��Դ

	//��������
public:
	//���캯��
	CCardResource();
	//��������
	virtual ~CCardResource();

	//���ܺ���
public:
	//������Դ
	bool LoadResource();
	//������Դ
	bool DestroyResource();
};

//////////////////////////////////////////////////////////////////////////

//�����˿�
class CHeapCard
{
	//���Ʊ���
protected:
	CPoint							m_ControlPoint;						//��׼λ��
	enDirection						m_CardDirection;					//�˿˷���

	//�˿˱���
protected:
	WORD							m_wFullCount;						//ȫ����Ŀ
	WORD							m_wMinusHeadCount;					//ͷ����ȱ
	WORD							m_wMinusLastCount;					//β����ȱ

	BYTE                            m_byShowCard;   // ��ʾ����
	BYTE                            m_byIndex;      // ��ʾ��λ��
	BYTE                            m_byMinusLastShowCard;

	//��������
public:
	//���캯��
	CHeapCard();
	//��������
	virtual ~CHeapCard();

	//���ܺ���
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC,CString s);
	//�����˿�
	bool SetCardData(WORD wMinusHeadCount, WORD wMinusLastCount, WORD wFullCount);

	void SetGodsCard(BYTE byCard, BYTE byIndex, BYTE byMinusLastShowCard);

	//�ؼ�����
public:
	//���÷���
	void SetDirection(enDirection Direction) { m_CardDirection=Direction; }
	//��׼λ��
	void SetControlPoint(int nXPos, int nYPos) { m_ControlPoint.SetPoint(nXPos,nYPos); }
};

//////////////////////////////////////////////////////////////////////////

//����˿�
class CWeaveCard
{
	//���Ʊ���
protected:
	bool							m_bDisplayItem;						//��ʾ��־
	CPoint							m_ControlPoint;						//��׼λ��
	enDirection						m_CardDirection;					//�˿˷���
	BYTE							m_cbDirectionCardPos;				//�����˿�				

	//�˿�����
protected:
	WORD							m_wCardCount;						//�˿���Ŀ
	BYTE							m_cbCardData[4];					//�˿�����
	BYTE							m_cbWikCard;
	//��������
public:
	//���캯��
	CWeaveCard();
	//��������
	virtual ~CWeaveCard();

	//���ܺ���
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC);
	//�滭�˿�
	void DrawCardControl(CDC * pDC, int nXPos, int nYPos);
	//�����˿�
	bool SetCardData(const BYTE cbCardData[], WORD wCardCount,BYTE cbWikCard=0);

	//�ؼ�����
public:
	//������ʾ
	void SetDisplayItem(bool bDisplayItem) { m_bDisplayItem=bDisplayItem; }
	//���÷���
	void SetDirection(enDirection Direction) { m_CardDirection=Direction; }
	//��׼λ��
	void SetControlPoint(int nXPos, int nYPos) { m_ControlPoint.SetPoint(nXPos,nYPos); }
	//������
	void SetDirectionCardPos(BYTE cbPos) { assert(cbPos <= 3); m_cbDirectionCardPos = cbPos;}
	WORD GetCardCount(){return m_wCardCount;}
	int	 GetControlXPos(){return m_ControlPoint.x;}
	int  GetControlYPox(){return m_ControlPoint.y;}

	//�ڲ�����
private:
	//��ȡ�˿�
	inline BYTE GetCardData(WORD wIndex);
};

//////////////////////////////////////////////////////////////////////////

//�û��˿�
class CUserCard
{
	//�˿�����
protected:
	WORD							m_wCardCount;						//�˿���Ŀ
	bool							m_bCurrentCard;						//��ǰ��־

	//���Ʊ���
protected:
	CPoint							m_ControlPoint;						//��׼λ��
	enDirection						m_CardDirection;					//�˿˷���

	//��������
public:
	//���캯��
	CUserCard();
	//��������
	virtual ~CUserCard();

	//���ܺ���
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC);
	//�����˿�
	bool SetCurrentCard(bool bCurrentCard);
	//�����˿�
	bool SetCardData(WORD wCardCount, bool bCurrentCard);

	//�ؼ�����
public:
	//���÷���
	void SetDirection(enDirection Direction) { m_CardDirection=Direction; }
	//��׼λ��
	void SetControlPoint(int nXPos, int nYPos) { m_ControlPoint.SetPoint(nXPos,nYPos); }
};

//////////////////////////////////////////////////////////////////////////

//�����˿�
class CDiscardCard
{
	//�˿�����
protected:
	WORD							m_wCardCount;						//�˿���Ŀ
	BYTE							m_cbCardData[28];					//�˿�����

	//���Ʊ���
protected:
	CPoint							m_ControlPoint;						//��׼λ��
	enDirection						m_CardDirection;					//�˿˷���

	//��������
public:
	//���캯��
	CDiscardCard();
	//��������
	virtual ~CDiscardCard();

	//���ܺ���
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC);
	//�����˿�
	bool AddCardItem(BYTE cbCardData);
	//�����˿�
	bool SetCardData(const BYTE cbCardData[], WORD wCardCount);
	//��ȡλ��
	CPoint GetLastCardPosition();

	//�ؼ�����
public:
	//���÷���
	void SetDirection(enDirection Direction) { m_CardDirection=Direction; }
	//��׼λ��
	void SetControlPoint(int nXPos, int nYPos) { m_ControlPoint.SetPoint(nXPos,nYPos); }
};

//////////////////////////////////////////////////////////////////////////

//�����˿�
class CTableCard
{
	//�˿�����
protected:
	WORD							m_wCardCount;						//�˿���Ŀ
	BYTE							m_cbCardData[MAX_COUNT];					//�˿�����

	//���Ʊ���
protected:
	CPoint							m_ControlPoint;						//��׼λ��
	enDirection						m_CardDirection;					//�˿˷���

	//��������
public:
	//���캯��
	CTableCard();
	//��������
	virtual ~CTableCard();

	//���ܺ���
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC);
	//�����˿�
	bool SetCardData(const BYTE cbCardData[], WORD wCardCount);

	//�ؼ�����
public:
	//���÷���
	void SetDirection(enDirection Direction) { m_CardDirection=Direction; }
	//��׼λ��
	void SetControlPoint(int nXPos, int nYPos) { m_ControlPoint.SetPoint(nXPos,nYPos); }
};

//////////////////////////////////////////////////////////////////////////

//�˿˽ṹ
struct tagCardItem
{
	bool							bShoot;								//�����־
	BYTE							cbCardData;							//�˿�����
};

//�˿˿ؼ�
class CCardControl
{
	//״̬����
protected:
	bool							m_bPositively;						//��Ӧ��־
	bool							m_bDisplayItem;						//��ʾ��־

	//λ�ñ���
protected:
	CPoint							m_BenchmarkPos;						//��׼λ��
	enXCollocateMode				m_XCollocateMode;					//��ʾģʽ
	enYCollocateMode				m_YCollocateMode;					//��ʾģʽ

	//�˿�����
protected:
	WORD							m_wCardCount;						//�˿���Ŀ
	WORD							m_wHoverItem;						//��������
	tagCardItem						m_CurrentCard;						//��ǰ�˿�
	tagCardItem						m_CardItemArray[MAX_COUNT];			//�˿�����

	//��Դ����
protected:
	CSize							m_ControlSize;						//�ؼ���С
	CPoint							m_ControlPoint;						//�ؼ�λ��

	BYTE                            m_cbOutCardIndex[MAX_INDEX];               // �Ѿ��������	
	bool                            m_bCardDisable[MAX_INDEX];
	bool                            m_bShowDisable;  // �Ƿ���ʾʹ�ܹ���

	//��������
public:
	//���캯��
	CCardControl();
	//��������
	virtual ~CCardControl();

	//��ѯ����
public:
	//��ȡ�˿�
	BYTE GetHoverCard();
	//��ȡ�˿�
	BYTE GetCurrentCard() { return m_CurrentCard.cbCardData; }

	BYTE GetMeOutCard();

	static BYTE                            m_byGodsData;

	//�˿˿���
public:
	//�����˿�
	bool SetCurrentCard(BYTE cbCardData);
	//�����˿�
	bool SetCurrentCard(tagCardItem CardItem);
	//�����˿�
	bool SetCardData(const BYTE cbCardData[], WORD wCardCount, BYTE cbCurrentCard);
	//�����˿�
	bool SetCardItem(const tagCardItem CardItemArray[], WORD wCardCount);

	void SetOutCardData(const BYTE cbCardDataIndex[], WORD wCardCount);
	void SetOutCardData(BYTE cbCardDataIndex);
	static void SetGodsCard(BYTE cbCardData);

	void UpdateCardDisable(bool bShowDisable=false);

	//�ؼ�����
public:
	//������Ӧ
	void SetPositively(bool bPositively) { m_bPositively=bPositively; }
	//������ʾ
	void SetDisplayItem(bool bDisplayItem) { m_bDisplayItem=bDisplayItem; }
	//��׼λ��
	void SetBenchmarkPos(int nXPos, int nYPos, enXCollocateMode XCollocateMode, enYCollocateMode YCollocateMode);
	//��׼λ��
	void SetBenchmarkPos(const CPoint & BenchmarkPos, enXCollocateMode XCollocateMode, enYCollocateMode YCollocateMode);

	//�¼�����
public:
	//�滭�˿�
	void DrawCardControl(CDC * pDC);
	//�����Ϣ
	bool OnEventSetCursor(CPoint Point, bool & bRePaint);

	//�ڲ�����
private:
	//�����л�
	WORD SwitchCardPoint(CPoint & MousePoint);
public:
	void SetShootCard(BYTE cbCard1=0, BYTE cbCard2=0, BYTE cbCard3=0);
	CWnd	*pWnd;
};

//////////////////////////////////////////////////////////////////////////

//��������
//��������
extern CCardResource				g_CardResource;						//�˿���Դ

//////////////////////////////////////////////////////////////////////////

#endif
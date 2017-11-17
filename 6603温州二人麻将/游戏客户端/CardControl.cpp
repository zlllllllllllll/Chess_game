#include "StdAfx.h"
#include "Resource.h"
#include "CardControl.h"
#include "GameClientView.h"
//////////////////////////////////////////////////////////////////////////
//�궨��

//��������
#define POS_SHOOT					5									//��������
#define POS_SPACE					16									//�ָ����
#define ITEM_COUNT					43									//������Ŀ
#define INVALID_ITEM				0xFFFF								//��Ч����

//�˿˴�С
#define CARD_WIDTH					45									//�˿˿�� 39
#define CARD_HEIGHT					69									//�˿˸߶�  64

//////////////////////////////////////////////////////////////////////////

//���캯��
CCardListImage::CCardListImage()
{
	//λ�ñ���
	m_nItemWidth=0;
	m_nItemHeight=0;
	m_nViewWidth=0;
	m_nViewHeight=0;

	return;
}

//��������
CCardListImage::~CCardListImage()
{
}

//������Դ
bool CCardListImage::LoadResource(UINT uResourceID, int nViewWidth, int nViewHeight)
{
	//������Դ
	m_CardListImage.LoadFromResource(AfxGetInstanceHandle(),uResourceID);
	m_csFlag.LoadFromResource(AfxGetInstanceHandle(),IDB_CS_FLAG);
	m_CardBack.LoadFromResource(AfxGetInstanceHandle(),IDB_CARD_BACK);
	//���ñ���
	m_nViewWidth=nViewWidth;
	m_nViewHeight=nViewHeight;
	m_nItemHeight=m_CardListImage.GetHeight();
	m_nItemWidth=m_CardListImage.GetWidth()/ITEM_COUNT;

	return true;
}

//�ͷ���Դ
bool CCardListImage::DestroyResource()
{
	//���ñ���
	m_nItemWidth=0;
	m_nItemHeight=0;

	//�ͷ���Դ
	m_CardListImage.Destroy();

	return true;
}

//��ȡλ��
int CCardListImage::GetImageIndex(BYTE cbCardData)
{
	//�����ж�
	if (cbCardData==0) 
		return 0;

	//����λ��
	BYTE cbValue=cbCardData&MASK_VALUE;
	BYTE cbColor=(cbCardData&MASK_COLOR)>>4;
	return (cbColor>=0x03)?(cbValue+27):(cbColor*9+cbValue);
}

//�滭�˿�
bool CCardListImage::DrawCardItem(CDC * pDestDC, BYTE cbCardData, int xDest, int yDest,BYTE cbGodsData,bool bDrawBack,int nItemWidth,int nItemHeight)
{
	//Ч��״̬
	ASSERT(m_CardListImage.IsNull()==false);
	ASSERT((m_nItemWidth!=0)&&(m_nItemHeight!=0));

	if(bDrawBack)
		m_CardBack.TransDrawImage(pDestDC,xDest-8,yDest-8,RGB(255,0,255));
	int nDrawWidth=m_nItemWidth;
	int nDrawHeight=m_nItemHeight;
	if(nItemHeight>0)nDrawHeight=nItemHeight;
	if(nItemWidth>0)nDrawWidth=nItemWidth;
	//�滭����
	if(cbCardData<=BAIBAN_CARD_DATA)
	{
		int nImageXPos=GetImageIndex(cbCardData)*m_nItemWidth;
		if(nDrawWidth==m_nItemWidth && nDrawHeight==m_nItemHeight)
			m_CardListImage.TransDrawImage(pDestDC,xDest,yDest,nDrawWidth,nDrawHeight,nImageXPos,0,RGB(255,0,255));
		else
			m_CardListImage.StretchBlt(pDestDC->GetSafeHdc(),xDest,yDest,nDrawWidth,nDrawHeight,nImageXPos,0,m_nItemWidth,m_nItemHeight,SRCCOPY);
	}
	if(cbGodsData!=0 && cbGodsData==cbCardData)
		m_csFlag.TransDrawImage(pDestDC,xDest+3,yDest,RGB(255,0,255));

	return true;
}

//////////////////////////////////////////////////////////////////////////

//���캯��
CCardResource::CCardResource()
{
}

//��������
CCardResource::~CCardResource()
{
}

//������Դ
bool CCardResource::LoadResource()
{
	//��������
	HINSTANCE hInstance=AfxGetInstanceHandle();

	//�û��˿�
	m_ImageUserTop.LoadFromResource(hInstance,IDB_CARD_USER_TOP);
	m_ImageUserLeft.LoadFromResource(hInstance,IDB_CARD_USER_LEFT);
	m_ImageUserRight.LoadFromResource(hInstance,IDB_CARD_USER_RIGHT);
	m_ImageUserBottom.LoadResource(IDB_CARD_USER_BOTTOM,CARD_WIDTH,CARD_HEIGHT);
	//m_ImageUserDisable.LoadResource(IDB_CARD_USER_DISABLE,CARD_WIDTH,CARD_HEIGHT);
	m_ImageWaveBottom.LoadResource(IDB_CARD_WAVE_BOTTOM,CARD_WIDTH,CARD_HEIGHT);
	//�����˿�
	m_ImageTableTop.LoadResource(IDB_CARD_TABLE_TOP,24,35);
	m_ImageTableLeft.LoadResource(IDB_CARD_TABLE_LEFT,32,28);
	m_ImageTableRight.LoadResource(IDB_CARD_TABLE_RIGHT,32,28);
	m_ImageTableBottom.LoadResource(IDB_CARD_TABLE_BOTTOM,24,35);
	

	//�ƶ��˿�
	m_ImageBackH.LoadFromResource(hInstance,IDB_CARD_BACK_H);
	m_ImageBackV.LoadFromResource(hInstance,IDB_CARD_BACK_V);
	m_ImageHeapSingleV.LoadFromResource(hInstance,IDB_CARD_HEAP_SINGLE_V);
	m_ImageHeapSingleH.LoadFromResource(hInstance,IDB_CARD_HEAP_SINGLE_H);
	m_ImageHeapDoubleV.LoadFromResource(hInstance,IDB_CARD_HEAP_DOUBLE_V);
	m_ImageHeapDoubleH.LoadFromResource(hInstance,IDB_CARD_HEAP_DOUBLE_H);

	return true;
}

//������Դ
bool CCardResource::DestroyResource()
{
	//�û��˿�
	m_ImageUserTop.Destroy();
	m_ImageUserLeft.Destroy();
	m_ImageUserRight.Destroy();
	m_ImageUserBottom.DestroyResource();
	//m_ImageUserDisable.DestroyResource();

	//�����˿�
	m_ImageTableTop.DestroyResource();
	m_ImageTableLeft.DestroyResource();
	m_ImageTableRight.DestroyResource();
	m_ImageTableBottom.DestroyResource();

	//�ƶ��˿�
	m_ImageBackH.Destroy();
	m_ImageBackV.Destroy();
	m_ImageHeapSingleV.Destroy();
	m_ImageHeapSingleH.Destroy();
	m_ImageHeapDoubleV.Destroy();
	m_ImageHeapDoubleH.Destroy();

	return true;
}

//////////////////////////////////////////////////////////////////////////

//���캯��
CHeapCard::CHeapCard()
{
	//���Ʊ���
	m_ControlPoint.SetPoint(0,0);
	m_CardDirection=Direction_East;

	//�˿˱���
	m_wFullCount=0;
	m_wMinusHeadCount=0;
	m_wMinusLastCount=0;

	m_byShowCard=0x00;   // ��ʾ����
	m_byIndex=0x00;      // ��ʾ��λ��
	m_byMinusLastShowCard = 0x00;
	return;
}

//��������
CHeapCard::~CHeapCard()
{
}

//�滭�˿�
void CHeapCard::DrawCardControl(CDC * pDC,CString s)
{
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{
			//�滭�˿�
			if ((m_wFullCount-m_wMinusHeadCount-m_wMinusLastCount)>0)
			{
				//��������
				int nXPos=0,nYPos=0;
				WORD wHeapIndex=m_wMinusHeadCount/2;
				WORD wDoubleHeap=(m_wMinusHeadCount+1)/2;
				WORD wDoubleLast=(m_wFullCount-m_wMinusLastCount)/2;
				WORD wFinallyIndex=(m_wFullCount-m_wMinusLastCount)/2;

				WORD wShowCardPos = m_wFullCount - m_byIndex - m_byMinusLastShowCard + 1;
				

				//ͷ���˿�
				if (m_wMinusHeadCount%2!=0)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+wHeapIndex*15+9;					
					g_CardResource.m_ImageHeapSingleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wHeapIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableRight.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}

				//�м��˿�
				for (WORD i=wDoubleHeap;i<wFinallyIndex;i++)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+i*15;
					g_CardResource.m_ImageHeapDoubleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((i + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0))
					{
						g_CardResource.m_ImageTableRight.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}

				//β���˿�
				if (m_wMinusLastCount%2!=0)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+wFinallyIndex*15+9;
					g_CardResource.m_ImageHeapSingleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wFinallyIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableRight.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}
			}
			pDC->TextOut(m_ControlPoint.x,m_ControlPoint.y,s);
			break;
		}
	case Direction_South:	//����
		{
			//�滭�˿�
			if ((m_wFullCount-m_wMinusHeadCount-m_wMinusLastCount)>0)
			{
				//��������
				int nXPos=0,nYPos=0;
				WORD wHeapIndex=m_wMinusLastCount/2;
				WORD wDoubleHeap=(m_wMinusLastCount+1)/2;
				WORD wDoubleLast=(m_wFullCount-m_wMinusHeadCount)/2;
				WORD wFinallyIndex=(m_wFullCount-m_wMinusHeadCount)/2;

				WORD wShowCardPos = m_byIndex + m_byMinusLastShowCard;				

				//β���˿�
				if (m_wMinusLastCount%2!=0)
				{
					nYPos=m_ControlPoint.y+6;
					nXPos=m_ControlPoint.x+wHeapIndex*18;
					g_CardResource.m_ImageHeapSingleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wHeapIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}

				//�м��˿�
				for (WORD i=wDoubleHeap;i<wFinallyIndex;i++)
				{
					nYPos=m_ControlPoint.y;
					nXPos=m_ControlPoint.x+i*18;
					g_CardResource.m_ImageHeapDoubleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((i + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0))
					{
						g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}

				//ͷ���˿�
				if (m_wMinusHeadCount%2!=0)
				{
					nYPos=m_ControlPoint.y+6;
					nXPos=m_ControlPoint.x+wFinallyIndex*18;
					g_CardResource.m_ImageHeapSingleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wFinallyIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}
			}
			pDC->TextOut(m_ControlPoint.x,m_ControlPoint.y,s);
			break;
		}
	case Direction_West:	//����
		{
			//�滭�˿�
			if ((m_wFullCount-m_wMinusHeadCount-m_wMinusLastCount)>0)
			{
				//��������
				int nXPos=0,nYPos=0;
				WORD wHeapIndex=m_wMinusLastCount/2;
				WORD wDoubleHeap=(m_wMinusLastCount+1)/2;
				WORD wDoubleLast=(m_wFullCount-m_wMinusHeadCount)/2;
				WORD wFinallyIndex=(m_wFullCount-m_wMinusHeadCount)/2;

				WORD wShowCardPos = m_byIndex + m_byMinusLastShowCard;
				//β���˿�
				if (m_wMinusLastCount%2!=0)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+wHeapIndex*15+9;
					g_CardResource.m_ImageHeapSingleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wHeapIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}

				//�м��˿�
				for (WORD i=wDoubleHeap;i<wFinallyIndex;i++)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+i*15;
					g_CardResource.m_ImageHeapDoubleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((i + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0))
					{
						g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}

				//ͷ���˿�
				if (m_wMinusHeadCount%2!=0)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+wFinallyIndex*15+9;
					g_CardResource.m_ImageHeapSingleV.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wFinallyIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,25,19);
					}
				}
			}
			pDC->TextOut(m_ControlPoint.x,m_ControlPoint.y,s);
			break;
		}
	case Direction_North:	//����
		{
			//�滭�˿�
			if ((m_wFullCount-m_wMinusHeadCount-m_wMinusLastCount)>0)
			{
				//��������
				int nXPos=0,nYPos=0;
				WORD wHeapIndex=m_wMinusHeadCount/2;
				WORD wDoubleHeap=(m_wMinusHeadCount+1)/2;
				WORD wDoubleLast=(m_wFullCount-m_wMinusLastCount)/2;
				WORD wFinallyIndex=(m_wFullCount-m_wMinusLastCount)/2;
				WORD wShowCardPos = m_wFullCount - m_byIndex - m_byMinusLastShowCard + 1;

				//ͷ���˿�
				if (m_wMinusHeadCount%2!=0)
				{
					nYPos=m_ControlPoint.y+6;
					nXPos=m_ControlPoint.x+wHeapIndex*18;
					g_CardResource.m_ImageHeapSingleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wHeapIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableTop.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}

				//�м��˿�
				for (WORD i=wDoubleHeap;i<wFinallyIndex;i++)
				{
					nYPos=m_ControlPoint.y;
					nXPos=m_ControlPoint.x+i*18;
					g_CardResource.m_ImageHeapDoubleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((i + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0))
					{
						g_CardResource.m_ImageTableTop.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}

				//β���˿�
				if (m_wMinusLastCount%2!=0)
				{
					nYPos=m_ControlPoint.y+6;
					nXPos=m_ControlPoint.x+wFinallyIndex*18;
					g_CardResource.m_ImageHeapSingleH.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
					if (((wFinallyIndex + 1) == (wShowCardPos+1)/2) && (m_byShowCard>0) && (0 == wShowCardPos%2))
					{
						g_CardResource.m_ImageTableTop.DrawCardItem(pDC,m_byShowCard,nXPos,nYPos,0,false,18,28);
					}
				}
			}
			pDC->TextOut(m_ControlPoint.x,m_ControlPoint.y,s);
			break;
		}
	}

	return;
}

//�����˿�
bool CHeapCard::SetCardData(WORD wMinusHeadCount, WORD wMinusLastCount, WORD wFullCount)
{
	//���ñ���
	m_wFullCount=wFullCount;
	m_wMinusHeadCount=wMinusHeadCount;
	m_wMinusLastCount=wMinusLastCount;
	if (0 == wFullCount)
	{
		m_byShowCard = 0;
	}
	return true;
}

void  CHeapCard::SetGodsCard(BYTE byCard, BYTE byIndex, BYTE byMinusLastShowCard)
{
	m_byShowCard = byCard;
	m_byIndex = byIndex;
	m_byMinusLastShowCard = byMinusLastShowCard;
}

//////////////////////////////////////////////////////////////////////////

//���캯��
CWeaveCard::CWeaveCard()
{
	//״̬����
	m_bDisplayItem=false;
	m_ControlPoint.SetPoint(0,0);
	m_CardDirection=Direction_South;
	m_cbDirectionCardPos = 1;

	//�˿�����
	m_wCardCount=0;
	ZeroMemory(&m_cbCardData,sizeof(m_cbCardData));
	m_cbWikCard=0;
	return;
}

//��������
CWeaveCard::~CWeaveCard()
{
}

//�滭�˿�
void CWeaveCard::DrawCardControl(CDC * pDC)
{
	//��ʾ�ж�
	if (m_wCardCount==0) 
		return;
	//��������
	int nXScreenPos=0,nYScreenPos=0;
	int nItemWidth=0,nItemHeight=0,nItemWidthEx=0,nItemHeightEx=0;

	//�滭�˿�
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{

			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y+i*g_CardResource.m_ImageTableRight.GetViewHeight()-8*i;
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,GetCardData(2-i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-8+g_CardResource.m_ImageTableRight.GetViewHeight();
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;
		}
	case Direction_South:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x+i*39;//g_CardResource.m_ImageTableBottom.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-g_CardResource.m_ImageWaveBottom.GetViewHeight();
				g_CardResource.m_ImageWaveBottom.DrawCardItem(pDC,GetCardData(i),nXScreenPos,nYScreenPos);
				if(m_cbWikCard!=0 && m_cbWikCard==GetCardData(i))
				{
					pDC->Draw3dRect(nXScreenPos+3,nYScreenPos+3,34,45,RGB(255,0,0),RGB(255,0,0));
				}
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x+g_CardResource.m_ImageWaveBottom.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-g_CardResource.m_ImageWaveBottom.GetViewHeight()-5*2;
				g_CardResource.m_ImageWaveBottom.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}
			break;
		}
	case Direction_West:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x;
				int nYScreenPos=m_ControlPoint.y+i*g_CardResource.m_ImageTableLeft.GetViewHeight()-8*i;
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,GetCardData(i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x;
				int nYScreenPos=m_ControlPoint.y+g_CardResource.m_ImageTableLeft.GetViewHeight()-8;
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;

		}
	case Direction_North:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nYScreenPos=m_ControlPoint.y;
				int nXScreenPos=m_ControlPoint.x-(i+1)*24;//g_CardResource.m_ImageTableTop.GetViewWidth();
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,GetCardData(2-i),nXScreenPos,nYScreenPos);
				if(m_cbWikCard!=0 && m_cbWikCard==GetCardData(2-i))
				{
					pDC->Draw3dRect(nXScreenPos+1,nYScreenPos+2,21,27,RGB(255,0,0),RGB(255,0,0));
				}
			}


			//�����˿�
			if (m_wCardCount==4)
			{
				int nYScreenPos=m_ControlPoint.y-5;
				int nXScreenPos=m_ControlPoint.x-2*24;//g_CardResource.m_ImageTableTop.GetViewWidth();
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;

		}
	}


	return;
}

//�����˿�
bool CWeaveCard::SetCardData(const BYTE cbCardData[], WORD wCardCount,BYTE cbWikCard)
{
	//Ч���С
	ASSERT(wCardCount<=CountArray(m_cbCardData));
	if (wCardCount>CountArray(m_cbCardData)) return false;

	//�����˿�
	m_wCardCount=wCardCount;
	CopyMemory(m_cbCardData,cbCardData,sizeof(BYTE)*wCardCount);

	m_cbWikCard=cbWikCard;
	return true;
}

//��ȡ�˿�
BYTE CWeaveCard::GetCardData(WORD wIndex)
{
	ASSERT(wIndex<CountArray(m_cbCardData));
	return ((m_bDisplayItem==true)||(wIndex==3))?m_cbCardData[wIndex]:0;
}
//�滭�˿�
void CWeaveCard::DrawCardControl(CDC * pDC, int nXPos, int nYPos)
{
	//����λ��
	SetControlPoint(nXPos,nYPos);

	//��ʾ�ж�
	if (m_wCardCount==0) 
		return;

	//��������
	int nXScreenPos=0,nYScreenPos=0;
	int nItemWidth=0,nItemHeight=0,nItemWidthEx=0,nItemHeightEx=0;

	//�滭�˿�
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{

			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y+i*g_CardResource.m_ImageTableRight.GetViewHeight();
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,GetCardData(2-i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x-g_CardResource.m_ImageTableRight.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-5+g_CardResource.m_ImageTableRight.GetViewHeight();
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;
	}
	case Direction_South:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x+i*g_CardResource.m_ImageTableBottom.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-g_CardResource.m_ImageTableBottom.GetViewHeight();
				g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,GetCardData(i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x+g_CardResource.m_ImageTableBottom.GetViewWidth();
				int nYScreenPos=m_ControlPoint.y-g_CardResource.m_ImageTableBottom.GetViewHeight()-5*2;
				g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}
			break;

		}
	case Direction_West:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nXScreenPos=m_ControlPoint.x;
				int nYScreenPos=m_ControlPoint.y+i*g_CardResource.m_ImageTableLeft.GetViewHeight();
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,GetCardData(i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nXScreenPos=m_ControlPoint.x;
				int nYScreenPos=m_ControlPoint.y+g_CardResource.m_ImageTableLeft.GetViewHeight()-5;
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;

		}
	case Direction_North:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<3;i++)
			{
				int nYScreenPos=m_ControlPoint.y;
				int nXScreenPos=m_ControlPoint.x-(i+1)*g_CardResource.m_ImageTableTop.GetViewWidth();
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,GetCardData(2-i),nXScreenPos,nYScreenPos);
			}

			//�����˿�
			if (m_wCardCount==4)
			{
				int nYScreenPos=m_ControlPoint.y-5;
				int nXScreenPos=m_ControlPoint.x-2*g_CardResource.m_ImageTableTop.GetViewWidth();
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,GetCardData(3),nXScreenPos,nYScreenPos);
			}

			break;

		}
	}

	return;
}

//////////////////////////////////////////////////////////////////////////

//���캯��
CUserCard::CUserCard()
{
	//�˿�����
	m_wCardCount=0;
	m_bCurrentCard=false;

	//���Ʊ���
	m_ControlPoint.SetPoint(0,0);
	m_CardDirection=Direction_East;

	return;
}

//��������
CUserCard::~CUserCard()
{
}

//�滭�˿�
void CUserCard::DrawCardControl(CDC * pDC)
{
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{
			//��ǰ�˿�
			if (m_bCurrentCard==true)
			{
				int nXPos=m_ControlPoint.x;
				int nYPos=m_ControlPoint.y;
				g_CardResource.m_ImageUserRight.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
			}

			//�����˿�
			if (m_wCardCount>0)
			{
				int nXPos=0,nYPos=0;
				for (WORD i=0;i<m_wCardCount;i++)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y+i*22+40;
					g_CardResource.m_ImageUserRight.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
				}
			}

			break;
		}
	case Direction_West:	//����
		{
			//�����˿�
			if (m_wCardCount>0)
			{
				int nXPos=0,nYPos=0;
				for (WORD i=0;i<m_wCardCount;i++)
				{
					nXPos=m_ControlPoint.x;
					nYPos=m_ControlPoint.y-(m_wCardCount-i-1)*22-92;
					g_CardResource.m_ImageUserLeft.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
				}
			}

			//��ǰ�˿�
			if (m_bCurrentCard==true)
			{
				int nXPos=m_ControlPoint.x;
				int nYPos=m_ControlPoint.y-49;
				g_CardResource.m_ImageUserLeft.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
			}

			break;
		}
	case Direction_North:	//����
		{
			//��ǰ�˿�
			if (m_bCurrentCard==true)
			{
				int nXPos=m_ControlPoint.x;
				int nYPos=m_ControlPoint.y;
				g_CardResource.m_ImageUserTop.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
			}

			//�����˿�
			if (m_wCardCount>0)
			{
				int nXPos=0,nYPos=0;
				for (WORD i=0;i<m_wCardCount;i++)
				{
					nYPos=m_ControlPoint.y;
					nXPos=m_ControlPoint.x+i*24+40;
					g_CardResource.m_ImageUserTop.TransDrawImage(pDC,nXPos,nYPos,RGB(255,0,255));
				}
			}

			break;
		}
	}

	return;
}

//�����˿�
bool CUserCard::SetCurrentCard(bool bCurrentCard)
{
	//���ñ���
	m_bCurrentCard=bCurrentCard;

	return true;
}

//�����˿�
bool CUserCard::SetCardData(WORD wCardCount, bool bCurrentCard)
{
	//���ñ���
	m_wCardCount=wCardCount;
	m_bCurrentCard=bCurrentCard;

	return true;
}

//////////////////////////////////////////////////////////////////////////

//���캯��
CDiscardCard::CDiscardCard()
{
	//�˿�����
	m_wCardCount=0;
	ZeroMemory(m_cbCardData,sizeof(m_cbCardData));

	//���Ʊ���
	m_ControlPoint.SetPoint(0,0);
	m_CardDirection=Direction_East;

	return;
}

//��������
CDiscardCard::~CDiscardCard()
{
}

//�滭�˿�
void CDiscardCard::DrawCardControl(CDC * pDC)
{
	//�滭����
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x+(i/8)*32;
				int nYPos=m_ControlPoint.y+(i%8)*20;
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,m_cbCardData[i],nXPos,nYPos);
			}

			break;
		}
	case Direction_West:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x-((m_wCardCount-1-i)/8)*32;
				int nYPos=m_ControlPoint.y-((m_wCardCount-1-i)%8)*20;
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,m_cbCardData[m_wCardCount-i-1],nXPos,nYPos);
			}

			break;
		}
	case Direction_South:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x-(i%14)*24;
				int nYPos=m_ControlPoint.y+(i/14)*38;
				g_CardResource.m_ImageTableBottom.DrawCardItem(pDC,m_cbCardData[i],nXPos,nYPos);
			}

			break;
		}
	case Direction_North:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x+((m_wCardCount-1-i)%14)*24;
				int nYPos=m_ControlPoint.y-((m_wCardCount-1-i)/14)*38-11;
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,m_cbCardData[m_wCardCount-i-1],nXPos,nYPos);
			}

			break;
		}
	}

	return;
}

//�����˿�
bool CDiscardCard::AddCardItem(BYTE cbCardData)
{
	//�����˿�
	if (m_wCardCount>=CountArray(m_cbCardData))
	{
		m_wCardCount--;
		MoveMemory(m_cbCardData,m_cbCardData+1,CountArray(m_cbCardData)-1);
	}

	//�����˿�
	m_cbCardData[m_wCardCount++]=cbCardData;

	return true;
}

//�����˿�
bool CDiscardCard::SetCardData(const BYTE cbCardData[], WORD wCardCount)
{
	//Ч���С
	//ASSERT(wCardCount<=CountArray(m_cbCardData));
	if (wCardCount>CountArray(m_cbCardData))
	{
		wCardCount = CountArray(m_cbCardData) -1;// �������������
		//return false;
	}
	//�����˿�
	m_wCardCount=wCardCount;
	CopyMemory(m_cbCardData,cbCardData,sizeof(m_cbCardData[0])*wCardCount);

	return true;
}
//��ȡλ��
CPoint CDiscardCard::GetLastCardPosition()
{
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{
			//��������
			int nCellWidth=g_CardResource.m_ImageTableRight.GetViewWidth();
			int nCellHeight=g_CardResource.m_ImageTableRight.GetViewHeight();
			int nXPos=m_ControlPoint.x+((m_wCardCount-1)/8)*30+5;
			int nYPos=m_ControlPoint.y+((m_wCardCount-1)%8)*20-15;


			return CPoint(nXPos,nYPos);
		}
	case Direction_West:	//����
		{
			//��������
			int nCellWidth=g_CardResource.m_ImageTableLeft.GetViewWidth();
			int nCellHeight=g_CardResource.m_ImageTableLeft.GetViewHeight();
			int nXPos=m_ControlPoint.x-((m_wCardCount-1)/8)*30;
			int nYPos=m_ControlPoint.y-((m_wCardCount-1)%8)*20-18;
			return CPoint(nXPos,nYPos);

		}
	case Direction_South:	//����
		{
			//��������
			int nCellWidth=g_CardResource.m_ImageTableBottom.GetViewWidth();
			int nCellHeight=g_CardResource.m_ImageTableBottom.GetViewHeight();
			int nXPos=m_ControlPoint.x-((m_wCardCount-1)%14)*24-5;
			int nYPos=m_ControlPoint.y+((m_wCardCount-1)/14)*38-8;

			return CPoint(nXPos,nYPos);

		}
	case Direction_North:	//����
		{
			//��������
			int nCellWidth=g_CardResource.m_ImageTableTop.GetViewWidth();
			int nCellHeight=g_CardResource.m_ImageTableTop.GetViewHeight();            
			int nXPos=m_ControlPoint.x+((m_wCardCount-1)%14)*24;
			int nYPos=m_ControlPoint.y+((-m_wCardCount+1)/14)*38-21;
			return CPoint(nXPos,nYPos);
		}
	}
	return CPoint(0,0);

}

//////////////////////////////////////////////////////////////////////////

//���캯��
CTableCard::CTableCard()
{
	//�˿�����
	m_wCardCount=0;
	ZeroMemory(m_cbCardData,sizeof(m_cbCardData));

	//���Ʊ���
	m_ControlPoint.SetPoint(0,0);
	m_CardDirection=Direction_East;

	return;
}

//��������
CTableCard::~CTableCard()
{
}

//�滭�˿�
void CTableCard::DrawCardControl(CDC * pDC)
{
	//�滭����
	switch (m_CardDirection)
	{
	case Direction_East:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x-33;
				int nYPos=m_ControlPoint.y+i*21;
				g_CardResource.m_ImageTableRight.DrawCardItem(pDC,m_cbCardData[m_wCardCount-i-1],nXPos,nYPos);
			}

			break;
		}
	case Direction_South:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nYPos=m_ControlPoint.y-g_CardResource.m_ImageWaveBottom.GetViewHeight();//-5;//-5-64;
				int nXPos=m_ControlPoint.x-(m_wCardCount-i)*39;
				g_CardResource.m_ImageWaveBottom.DrawCardItem(pDC,m_cbCardData[i],nXPos,nYPos);
			}

			break;
		}
	case Direction_West:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nXPos=m_ControlPoint.x;
				int nYPos=m_ControlPoint.y-(m_wCardCount-i)*21;
				g_CardResource.m_ImageTableLeft.DrawCardItem(pDC,m_cbCardData[i],nXPos,nYPos);
			}

			break;
		}
	case Direction_North:	//����
		{
			//�滭�˿�
			for (WORD i=0;i<m_wCardCount;i++)
			{
				int nYPos=m_ControlPoint.y;
				int nXPos=m_ControlPoint.x+i*24;
				g_CardResource.m_ImageTableTop.DrawCardItem(pDC,m_cbCardData[m_wCardCount-i-1],nXPos,nYPos);
			}
			break;
		}
	}

	return;
}

//�����˿�
bool CTableCard::SetCardData(const BYTE cbCardData[], WORD wCardCount)
{
	//Ч���С
	ASSERT(wCardCount<=CountArray(m_cbCardData));
	if (wCardCount>CountArray(m_cbCardData))
		return false;

	//�����˿�
	m_wCardCount=wCardCount;
	CopyMemory(m_cbCardData,cbCardData,sizeof(m_cbCardData[0])*wCardCount);

	return true;
}

//////////////////////////////////////////////////////////////////////////
BYTE   CCardControl::m_byGodsData=0x00;
//���캯��
CCardControl::CCardControl()
{
	//״̬����
	m_bPositively=false;
	m_bDisplayItem=false;

	//λ�ñ���
	m_XCollocateMode=enXCenter;
	m_YCollocateMode=enYCenter;
	m_BenchmarkPos.SetPoint(0,0);

	//�˿�����
	m_wCardCount=0;
	m_wHoverItem=INVALID_ITEM;
	ZeroMemory(&m_CurrentCard,sizeof(m_CurrentCard));
	ZeroMemory(&m_CardItemArray,sizeof(m_CardItemArray));

	//��������
	m_ControlPoint.SetPoint(0,0);
	m_ControlSize.cy=CARD_HEIGHT+POS_SHOOT;
	m_ControlSize.cx=(CountArray(m_CardItemArray)+1)*CARD_WIDTH+POS_SPACE;
	ZeroMemory(m_cbOutCardIndex, sizeof(m_cbOutCardIndex));
	ZeroMemory(m_bCardDisable, sizeof(m_bCardDisable));
	m_bShowDisable = false;
	pWnd=NULL;
	HINSTANCE hInstance=AfxGetInstanceHandle();
	return;
}

//��������
CCardControl::~CCardControl()
{
}

//��׼λ��
void CCardControl::SetBenchmarkPos(int nXPos, int nYPos, enXCollocateMode XCollocateMode, enYCollocateMode YCollocateMode)
{
	//���ñ���
	m_BenchmarkPos.x=nXPos;
	m_BenchmarkPos.y=nYPos;
	m_XCollocateMode=XCollocateMode;
	m_YCollocateMode=YCollocateMode;

	//����λ��
	switch (m_XCollocateMode)
	{
	case enXLeft:	{ m_ControlPoint.x=m_BenchmarkPos.x; break; }
	case enXCenter: { m_ControlPoint.x=m_BenchmarkPos.x-m_ControlSize.cx/2; break; }
	case enXRight:	{ m_ControlPoint.x=m_BenchmarkPos.x-m_ControlSize.cx; break; }
	}

	//����λ��
	switch (m_YCollocateMode)
	{
	case enYTop:	{ m_ControlPoint.y=m_BenchmarkPos.y; break; }
	case enYCenter: { m_ControlPoint.y=m_BenchmarkPos.y-m_ControlSize.cy/2; break; }
	case enYBottom: { m_ControlPoint.y=m_BenchmarkPos.y-m_ControlSize.cy; break; }
	}

	return;
}

//��׼λ��
void CCardControl::SetBenchmarkPos(const CPoint & BenchmarkPos, enXCollocateMode XCollocateMode, enYCollocateMode YCollocateMode)
{
	//���ñ���
	m_BenchmarkPos=BenchmarkPos;
	m_XCollocateMode=XCollocateMode;
	m_YCollocateMode=YCollocateMode;

	//����λ��
	switch (m_XCollocateMode)
	{
	case enXLeft:	{ m_ControlPoint.x=m_BenchmarkPos.x; break; }
	case enXCenter: { m_ControlPoint.x=m_BenchmarkPos.x-m_ControlSize.cx/2; break; }
	case enXRight:	{ m_ControlPoint.x=m_BenchmarkPos.x-m_ControlSize.cx; break; }
	}

	//����λ��
	switch (m_YCollocateMode)
	{
	case enYTop:	{ m_ControlPoint.y=m_BenchmarkPos.y; break; }
	case enYCenter: { m_ControlPoint.y=m_BenchmarkPos.y-m_ControlSize.cy/2; break; }
	case enYBottom: { m_ControlPoint.y=m_BenchmarkPos.y-m_ControlSize.cy; break; }
	}

	return;
}

//��ȡ�˿�
BYTE CCardControl::GetHoverCard()
{
	//��ȡ�˿�
	BYTE byCardData = 0x00;
	if (m_wHoverItem!=INVALID_ITEM)
	{
		if (m_wHoverItem==CountArray(m_CardItemArray))
		{
			byCardData =  m_CurrentCard.cbCardData;
		}
		else
		{
			byCardData = m_CardItemArray[m_wHoverItem].cbCardData;
		}
		CGameLogic gameLogic;
		gameLogic.SetGodsCard(m_byGodsData);
		BYTE byIndex = gameLogic.SwitchToCardIndex(byCardData);
		if (m_bCardDisable[byIndex])
		{
			byCardData = 0x00;
		}

		if (byCardData == m_byGodsData)
		{
			bool bAllGods = true;
			if (m_CurrentCard.cbCardData != m_byGodsData)
			{
				bAllGods = false;
			}
			if (bAllGods)
			{
				for (int i=0; i<m_wCardCount; ++i)
				{
					if (m_CardItemArray[i].cbCardData != m_byGodsData)
					{
						bAllGods = false;
						break;
					}
				}
			}
			if (!bAllGods)
			{
				byCardData = 0x00;
			}
			
		}
	}
	
	return byCardData;
}

//�����˿�
bool CCardControl::SetCurrentCard(BYTE cbCardData)
{
	//���ñ���
	m_CurrentCard.bShoot=false;
	m_CurrentCard.cbCardData=cbCardData;
	return true;
}

//�����˿�
bool CCardControl::SetCurrentCard(tagCardItem CardItem)
{
	//���ñ���
	m_CurrentCard.bShoot=CardItem.bShoot;
	m_CurrentCard.cbCardData=CardItem.cbCardData;
	return true;
}

//�����˿�
bool CCardControl::SetCardData(const BYTE cbCardData[], WORD wCardCount, BYTE cbCurrentCard)
{
	//Ч���С
	ASSERT(wCardCount<=CountArray(m_CardItemArray));
	if (wCardCount>CountArray(m_CardItemArray)) 
		return false;

	//��ǰ�˿�
	m_CurrentCard.bShoot=false;
	m_CurrentCard.cbCardData=cbCurrentCard;

	//�����˿�
	m_wCardCount=wCardCount;
	for (WORD i=0;i<m_wCardCount;i++)
	{
		m_CardItemArray[i].bShoot=false;
		m_CardItemArray[i].cbCardData=cbCardData[i];
	}
	return true;
}

//�����˿�
bool CCardControl::SetCardItem(const tagCardItem CardItemArray[], WORD wCardCount)
{
	//Ч���С
	ASSERT(wCardCount<=CountArray(m_CardItemArray));
	if (wCardCount>CountArray(m_CardItemArray))
		return false;

	//�����˿�
	m_wCardCount=wCardCount;
	for (WORD i=0;i<m_wCardCount;i++)
	{
		m_CardItemArray[i].bShoot=CardItemArray[i].bShoot;
		m_CardItemArray[i].cbCardData=CardItemArray[i].cbCardData;
	}
	return true;
}

void CCardControl::SetOutCardData(const BYTE cbCardDataIndex[], WORD wCardCount)
{
	ZeroMemory(m_cbOutCardIndex, sizeof(m_cbOutCardIndex));
	if (NULL != cbCardDataIndex)
	{
		CopyMemory(m_cbOutCardIndex, cbCardDataIndex, wCardCount);
	}
}

void CCardControl::SetOutCardData(BYTE cbCardDataIndex)
{
	if (cbCardDataIndex>sizeof(m_cbOutCardIndex)/sizeof(m_cbOutCardIndex[0]))
	{
		return ;
	}
	++m_cbOutCardIndex[cbCardDataIndex];
}

void CCardControl::SetGodsCard(BYTE cbCardData)
{
	m_byGodsData = cbCardData;
}

void CCardControl::UpdateCardDisable(bool bShowDisable)
{
	ZeroMemory(m_bCardDisable, sizeof(m_bCardDisable));
	m_bShowDisable = bShowDisable;
	if (!bShowDisable)
	{
		return ;
	}
	CGameLogic gameLogic;
	gameLogic.SetGodsCard(m_byGodsData);

	// ֻҪ�е��ŵķ磬 ���е������ƶ�Ҫ���
	bool bHaveSingle = false;
	BYTE byIndexCount[MAX_INDEX];  // �Ƶ�����
	ZeroMemory(byIndexCount, sizeof(byIndexCount));
	if (0x00 == m_byGodsData)
	{
		return ;
	}
	BYTE byGodsIndex = gameLogic.SwitchToCardIndex(m_byGodsData);
	for (WORD i=0;i<m_wCardCount; ++i)
	{
		BYTE cbCardData=(m_bDisplayItem==true)?m_CardItemArray[i].cbCardData:0;
		if ((0x00 != cbCardData)
			&& (m_byGodsData != cbCardData))
		{
			BYTE byIndex = gameLogic.SwitchToCardIndex(cbCardData);
			++byIndexCount[byIndex];
		}
		
	}

	if (m_CurrentCard.cbCardData!=0)
	{
		BYTE cbCardData=(m_bDisplayItem==true)?m_CurrentCard.cbCardData:0;
		if ((0x00 != cbCardData)
			&& (m_byGodsData != cbCardData))
		{
			BYTE byIndex = gameLogic.SwitchToCardIndex(cbCardData);
			++byIndexCount[byIndex];
		}
	}

	// ���ŷ�
	for (WORD i=27; i<MAX_INDEX; ++i)
	{
		if ((1 == byIndexCount[i]) && (byGodsIndex != i))
		{
			bHaveSingle = true;
			break;
		}
	}
	if (!bHaveSingle) // û�е��ŵķ�,�����ƿ��Գ�
	{
		ZeroMemory(m_bCardDisable, sizeof(m_bCardDisable));
		return ;
	}

	// �Ȱ����е��ƶ���ʼ��Ϊ�����Գ�
	bHaveSingle = false;  // �Ƿ���ڵ����Ѿ�����
	bool bHaveDouble = false;
	for (WORD i=0; i<MAX_INDEX; ++i)
	{
		m_bCardDisable[i] = true;
		if ((i<27) || (byGodsIndex == i))
		{
			continue ;
		}

		// ���Ѿ��������ҵ�����
		if (m_cbOutCardIndex[i]>0) // �Ѿ�����
		{
			bHaveDouble = true;
			m_bCardDisable[i]=false;
			if (1 == byIndexCount[i])
			{
				bHaveSingle = true;
			}
		}
	}
	// ���еĵ��ƶ����Գ�
	if (!bHaveSingle)
	{
		for (WORD i=27; i<MAX_INDEX; ++i)
		{
			if (byGodsIndex == i)
			{
				continue ;
			}

			if ((1 == byIndexCount[i]) || (!bHaveDouble && byIndexCount[i]>0))
			{
				m_bCardDisable[i]=false;
			}
		}
	}
}

//�滭�˿�
void CCardControl::DrawCardControl(CDC * pDC)
{
	//�滭׼��
	int nXExcursion=m_ControlPoint.x+(CountArray(m_CardItemArray)-m_wCardCount)*CARD_WIDTH;

	CGameLogic gameLogic;
	gameLogic.SetGodsCard(m_byGodsData);
	//�滭�˿�
	for (WORD i=0;i<m_wCardCount;i++)
	{
		//����λ��
		int nXScreenPos=nXExcursion+CARD_WIDTH*i;
		int nYScreenPos=m_ControlPoint.y+(((m_CardItemArray[i].bShoot==false)&&(m_wHoverItem!=i))?POS_SHOOT:0);

		//�滭�˿�
		BYTE cbCardData=(m_bDisplayItem==true)?m_CardItemArray[i].cbCardData:0;
		if ((0 != cbCardData) && m_bShowDisable)
		{
			BYTE byIndex = gameLogic.SwitchToCardIndex(cbCardData);
			g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,cbCardData,nXScreenPos,nYScreenPos,m_byGodsData);
			//if (m_bCardDisable[byIndex])
			//{
			//	g_CardResource.m_ImageUserDisable.DrawCardItem(pDC,cbCardData,nXScreenPos,nYScreenPos,m_byGodsData);
			//}
			//else
			//{
			//}
		}
		else
		{
			g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,cbCardData,nXScreenPos,nYScreenPos,m_byGodsData);
		}		
	}

	//��ǰ�˿�
	if (m_CurrentCard.cbCardData!=0)
	{
		//����λ��
		int nXScreenPos=/*nXExcursion+CARD_WIDTH*m_wCardCount;*/m_ControlPoint.x+m_ControlSize.cx-CARD_WIDTH;
		int nYScreenPos=m_ControlPoint.y+(((m_CurrentCard.bShoot==false)&&(m_wHoverItem!=CountArray(m_CardItemArray)))?POS_SHOOT:0);

		//�滭�˿�
		BYTE cbCardData=(m_bDisplayItem==true)?m_CurrentCard.cbCardData:0;
		if ((0 != cbCardData) && m_bShowDisable)
		{
			BYTE byIndex = gameLogic.SwitchToCardIndex(cbCardData);
			g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,cbCardData,nXScreenPos,nYScreenPos,m_byGodsData,true);
		}
		else
		{
			g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,cbCardData,nXScreenPos,nYScreenPos,m_byGodsData,true);
		}
	}

	return;
}

//�����л�
WORD CCardControl::SwitchCardPoint(CPoint & MousePoint)
{
	//��׼λ��
	int nXPos=MousePoint.x-m_ControlPoint.x;
	int nYPos=MousePoint.y-m_ControlPoint.y;

	//��Χ�ж�
	if ((nXPos<0)||(nXPos>m_ControlSize.cx)) 
		return INVALID_ITEM;
	if ((nYPos<POS_SHOOT)||(nYPos>m_ControlSize.cy)) 
		return INVALID_ITEM;

	//��������
	if (nXPos<CARD_WIDTH*CountArray(m_CardItemArray))
	{
		WORD wViewIndex=(WORD)(nXPos/CARD_WIDTH)+m_wCardCount;
		if (wViewIndex>=CountArray(m_CardItemArray))
			return wViewIndex-CountArray(m_CardItemArray);
		return INVALID_ITEM;
	}

	//��ǰ����
	if ((m_CurrentCard.cbCardData!=0)&&(nXPos>=(m_ControlSize.cx-CARD_WIDTH))) 
		return CountArray(m_CardItemArray);

	return INVALID_ITEM;
}

//�����Ϣ
bool CCardControl::OnEventSetCursor(CPoint Point, bool & bRePaint)
{
	//��ȡ����
	WORD wHoverItem=SwitchCardPoint(Point);

	//��Ӧ�ж�
	if ((m_bPositively==false)&&(m_wHoverItem!=INVALID_ITEM))
	{
		bRePaint=true;
		m_wHoverItem=INVALID_ITEM;
	}

	//�����ж�
	if ((wHoverItem!=m_wHoverItem)&&(m_bPositively==true))
	{
		bRePaint=true;
		m_wHoverItem=wHoverItem;
		SetCursor(LoadCursor(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDC_CARD_CUR)));
	}

	return (wHoverItem!=INVALID_ITEM);
}

BYTE CCardControl::GetMeOutCard()
{
	CGameLogic gameLogic;
	gameLogic.SetGodsCard(m_byGodsData);

	BYTE iIndex = gameLogic.SwitchToCardIndex(m_CurrentCard.cbCardData);
	if (!m_bCardDisable[iIndex] && (m_CurrentCard.cbCardData!= m_byGodsData))
	{
		return m_CurrentCard.cbCardData;
	}

	for (WORD i=0;i<m_wCardCount;i++)
	{
		BYTE cbCardData=m_CardItemArray[i].cbCardData;
		iIndex = gameLogic.SwitchToCardIndex(cbCardData);
		if (!m_bCardDisable[iIndex] && (cbCardData!= m_byGodsData))
		{
			return cbCardData;
		}
	}
	if (m_wCardCount>0)
	{
		BYTE cbCardData=m_CardItemArray[0].cbCardData;
		return cbCardData;
	}
	return 0x00;
}
//////////////////////////////////////////////////////////////////////////

//��������
CCardResource						g_CardResource;						//�˿���Դ

//////////////////////////////////////////////////////////////////////////

void CCardControl::SetShootCard(BYTE cbCard1, BYTE cbCard2, BYTE cbCard3)
{
	//��ȫ������
	if(cbCard1==0 && cbCard2==0 && cbCard3==0)
	{
		for (WORD i=0;i<m_wCardCount;i++)
			m_CardItemArray[i].bShoot=false;
	}
	bool b1=false,b2=false,b3=false;
	for (WORD i=0;i<m_wCardCount;i++)
	{
		if(m_CardItemArray[i].cbCardData==cbCard1 && !b1)
		{
			m_CardItemArray[i].bShoot=true;
			b1=true;
		}
		if(m_CardItemArray[i].cbCardData==cbCard2 && !b2)
		{
			m_CardItemArray[i].bShoot=true;
			b2=true;
		}
		if(m_CardItemArray[i].cbCardData==cbCard3 && !b3)
		{
			m_CardItemArray[i].bShoot=true;
			b3=true;
		}
	}
	((CGameClientView*)(pWnd))->RefreshGameView();
}

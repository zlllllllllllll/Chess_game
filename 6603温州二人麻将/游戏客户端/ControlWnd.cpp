#include "StdAfx.h"
#include "..\��Ϣ����\GameLogic.h"
#include "ControlWnd.h"
#include "CardControl.h"

//////////////////////////////////////////////////////////////////////////

//��ť��ʶ
#define IDC_CHIHU					100									//�Ժ���ť
#define IDC_LISTEN					101									//���ư�ť
#define IDC_GIVEUP					102									//������ť
#define IDC_CHI_SHANG				103
#define IDC_CHI_ZHONG				104
#define IDC_CHI_XIA					105
#define IDC_PENG					106
#define IDC_GANG					107

//λ�ñ�ʶ
#define ITEM_WIDTH					90									//������
#define ITEM_HEIGHT					44									//����߶�

#define CONTROL_TOP 				35									//���Ƹ߶�
#define CONTROL_WIDTH				173									//���ƿ��
#define CONTROL_HEIGHT				47									//���Ƹ߶�

//////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CControlWnd, CWnd)
	ON_WM_PAINT()
	ON_WM_CREATE()
	ON_WM_SETCURSOR()
	ON_WM_LBUTTONDOWN()
	ON_BN_CLICKED(IDC_CHIHU, OnChiHu)
	ON_BN_CLICKED(IDC_LISTEN, OnListen)
	ON_BN_CLICKED(IDC_GIVEUP, OnGiveUp)
	ON_BN_CLICKED(IDC_CHI_SHANG,OnChiShang)
	ON_BN_CLICKED(IDC_CHI_ZHONG,OnChiZhong)
	ON_BN_CLICKED(IDC_CHI_XIA,OnChiXia)
	ON_BN_CLICKED(IDC_PENG,OnPeng)
	ON_BN_CLICKED(IDC_GANG,OnGang)
	ON_WM_CTLCOLOR()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////////

//���캯��
CControlWnd::CControlWnd()
{
	//���ñ���
	//�ڲ�����
	m_pSinkWindow=NULL;
	m_cbActionMask=0;
	m_cbCenterCard=0;
	m_PointBenchmark.SetPoint(0,0);
	ZeroMemory(m_cbGangCard,sizeof(m_cbGangCard));

	//״̬����
	m_cbItemCount=0;
	m_cbCurrentItem=0xFF;

	//������Դ
	HINSTANCE hInstance=AfxGetInstanceHandle();
	m_ImageActionExplain.LoadFromResource(hInstance,IDB_ACTION_EXPLAIN);
    m_ImageControlTop.LoadFromResource(hInstance,IDB_CONTROL_TOP);
    m_ImageControlMid.LoadFromResource(hInstance,IDB_CONTROL_MID);
    m_ImageControlButtom.LoadFromResource(hInstance,IDB_CONTROL_BOTTOM);

	m_cardControl=NULL;
	return;
}

//��������
CControlWnd::~CControlWnd()
{
}

//��׼λ��
void CControlWnd::SetBenchmarkPos(int nXPos, int nYPos)
{
	//λ�ñ���
	m_PointBenchmark.SetPoint(nXPos,nYPos);

	//�����ؼ�
	RectifyControl();

	return;
}
//���ô���
void CControlWnd::SetSinkWindow(CWnd * pSinkWindow)
{
	//���ñ���
	m_pSinkWindow=pSinkWindow;

	return;
}

//�����˿�
void CControlWnd::SetControlInfo(BYTE cbCenterCard, BYTE cbActionMask, tagGangCardResult & GangCardResult)
{
	//���ñ���
	m_cbItemCount=0;
	m_cbCurrentItem=0xFF;
	m_cbActionMask=cbActionMask;
	m_cbCenterCard=cbCenterCard;

	//m_btChiShang.EnableWindow(FALSE);
	//m_btChiXia.EnableWindow(FALSE);
	//m_btChiZhong.EnableWindow(FALSE);
	//m_btPeng.EnableWindow(FALSE);
	//m_btGang.EnableWindow(FALSE);

	//������Ϣ
	ZeroMemory(m_cbGangCard,sizeof(m_cbGangCard));
	for (BYTE i=0;i<GangCardResult.cbCardCount;i++) 
	{
		m_cbItemCount++;
		m_cbGangCard[i]=GangCardResult.cbCardData[i];
	}

	//������Ŀ
	BYTE cbItemKind[4]={WIK_LEFT,WIK_CENTER,WIK_RIGHT,WIK_PENG};
	//m_btChiShang.EnableWindow(cbActionMask & WIK_LEFT);
	//m_btChiZhong.EnableWindow(cbActionMask & WIK_CENTER);
	//m_btChiXia.EnableWindow(cbActionMask & WIK_RIGHT);
	//m_btPeng.EnableWindow(cbActionMask & WIK_PENG);
	
	for (BYTE i=0;i<CountArray(cbItemKind);i++) 
	{
		if ((m_cbActionMask&cbItemKind[i])!=0) 
			m_cbItemCount++;
	}

	//��ť����
	m_btChiHu.EnableWindow(cbActionMask&WIK_CHI_HU);
	//m_btListen.EnableWindow(cbActionMask&WIK_LISTEN);

	//�����ؼ�
	RectifyControl();

	if (WIK_NULL != (cbActionMask&~WIK_LISTEN))
	{
		//��ʾ����
		ShowWindow(SW_SHOW);
	}
	return;
}

//�����ؼ�
void CControlWnd::RectifyControl()
{
	//����λ��
	CRect rcRect;
	rcRect.right=m_PointBenchmark.x;
	rcRect.bottom=m_PointBenchmark.y;
	rcRect.left=m_PointBenchmark.x-CONTROL_WIDTH;
	rcRect.top=m_PointBenchmark.y-ITEM_HEIGHT*m_cbItemCount-CONTROL_HEIGHT-CONTROL_TOP;

	//�ƶ�����
	MoveWindow(&rcRect);

    //������ť
    CRect rcButton;
    m_btChiHu.GetWindowRect(&rcButton);
    int nYPos=rcRect.Height()-rcButton.Height()-7;
    m_btChiHu.SetWindowPos(NULL,rcRect.Width()-70-rcButton.Width()-2,nYPos,0,0,SWP_NOZORDER|SWP_NOSIZE);
    m_btGiveUp.SetWindowPos(NULL,rcRect.Width()-70,nYPos+3,0,0,SWP_NOZORDER|SWP_NOSIZE);

	////������ť
	//m_btChiHu.GetWindowRect(&rcButton);
	//nYPos=rcRect.Height()-rcButton.Height()-9;
	////���� 25
	//m_btChiShang.SetWindowPos(NULL,25,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////���� 84
	//m_btChiZhong.SetWindowPos(NULL,84,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////���� 143
	//m_btChiXia.SetWindowPos(NULL,143,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////�� 202
	//m_btPeng.SetWindowPos(NULL,202,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////�� 238
	//m_btGang.SetWindowPos(NULL,238,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////��
	//m_btChiHu.SetWindowPos(NULL,274,40/*rcRect.Width()-rcButton.Width()*3-14,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////m_btListen.SetWindowPos(NULL,rcRect.Width()-rcButton.Width()*2-11,nYPos,0,0,SWP_NOZORDER|SWP_NOSIZE);
	//m_btGiveUp.SetWindowPos(NULL,320,43/*rcRect.Width()-rcButton.Width()-8,nYPos*/,0,0,SWP_NOZORDER|SWP_NOSIZE);
	////m_btListen.ShowWindow(SW_HIDE);

	return;
}

//�Ժ���ť
void CControlWnd::OnChiHu()
{
	CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_CHI_HU,0);
	return;
}

//���ư�ť
void CControlWnd::OnListen()
{
	CGameFrameView::GetInstance()->PostEngineMessage(IDM_LISTEN_CARD,0,0);
	return;
}
void CControlWnd::OnChiShang()
{
	if ((m_cbActionMask&WIK_LEFT)!=0)
	{
		CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_LEFT,m_cbCenterCard);
		return;
	}
	return;
}
void CControlWnd::OnChiZhong()
{
	if ((m_cbActionMask&WIK_CENTER)!=0)
	{
		CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_CENTER,m_cbCenterCard);
		return;
	}
	return;
}
void CControlWnd::OnChiXia()
{
	if ((m_cbActionMask&WIK_RIGHT)!=0)
	{
		CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_RIGHT,m_cbCenterCard);
		return;
	}
	return;
}
void CControlWnd::OnPeng()
{
	if ((m_cbActionMask&WIK_PENG)!=0)
	{
		CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_PENG,m_cbCenterCard);
		return;
	}
	return;
}
void CControlWnd::OnGang()
{
	for (BYTE i=0;i<CountArray(m_cbGangCard);i++)
	{
		if ((m_cbGangCard[i]!=0))
		{
			CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_GANG,m_cbGangCard[i]);
			return;
		}
	}
	return;
}


//������ť
void CControlWnd::OnGiveUp()
{
	CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_NULL,0);
	return;
}

//�ػ�����
void CControlWnd::OnPaint()
{
	CPaintDC dc(this);

	//��ȡλ��
	CRect rcClient;
	GetClientRect(&rcClient);

	//��������
	CDC BufferDC;
	CBitmap BufferImage;
	BufferDC.CreateCompatibleDC(&dc);
	BufferImage.CreateCompatibleBitmap(&dc,rcClient.Width(),rcClient.Height());
	BufferDC.SelectObject(&BufferImage);

    //��䱳��
    BufferDC.FillSolidRect(rcClient,RGB(0,96,124));

	//�滭����
	m_ImageControlTop.TransDrawImage(&BufferDC,0,0,RGB(255,0,255));
	for (int nImageYPos=m_ImageControlTop.GetHeight();nImageYPos<rcClient.Height();nImageYPos+=m_ImageControlMid.GetHeight())
	{
		m_ImageControlMid.BitBlt(BufferDC,0,nImageYPos);
	}
	m_ImageControlButtom.TransDrawImage(&BufferDC,0,rcClient.Height()-m_ImageControlButtom.GetHeight(),RGB(255,0,255));

	//��������
	int nYPos=35;
	BYTE cbCurrentItem=0;
	BYTE cbExcursion[3]={0,1,2};
	BYTE cbItemKind[4]={WIK_LEFT,WIK_CENTER,WIK_RIGHT,WIK_PENG};

	
	//�滭�˿�
	for (BYTE i=0;i<CountArray(cbItemKind);i++)
	{
		if ((m_cbActionMask&cbItemKind[i])!=0)
		{
			//�滭�˿�
			for (BYTE j=0;j<3;j++)
			{
				BYTE cbCardData=m_cbCenterCard;
				if (i<CountArray(cbExcursion))  // ����
				{
					if ((BAIBAN_CARD_DATA == m_cbCenterCard) && (CCardControl::m_byGodsData>0))
					{
						cbCardData = CCardControl::m_byGodsData;
					}
					cbCardData=cbCardData+j-cbExcursion[i];

					// �װ屾����Ҫ��ԭ
					if (cbCardData == CCardControl::m_byGodsData)
					{
						cbCardData = BAIBAN_CARD_DATA;
					}
				}
				g_CardResource.m_ImageTableBottom.DrawCardItem(&BufferDC,cbCardData,j*26+12,nYPos+5);
			}

			//����λ��
			int nXImagePos=0;
			int nItemWidth=m_ImageActionExplain.GetWidth()/7;
			if ((m_cbActionMask&cbItemKind[i])&WIK_PENG)
				nXImagePos=nItemWidth;

			//�滭��־
			int nItemHeight=m_ImageActionExplain.GetHeight();
			m_ImageActionExplain.BitBlt(BufferDC,126,nYPos+5,nItemWidth,nItemHeight,nXImagePos,0);

			//�滭�߿�
			if (cbCurrentItem==m_cbCurrentItem)
			{
				BufferDC.Draw3dRect(5,nYPos,rcClient.Width()-5*2,ITEM_HEIGHT,RGB(255,255,0),RGB(255,255,0));
			}

			//���ñ���
			++cbCurrentItem;
			nYPos+=ITEM_HEIGHT;
		}
	}

	//�����˿�
	for (BYTE i=0;i<CountArray(m_cbGangCard);i++)
	{
		if (m_cbGangCard[i]!=0)
		{
			//m_btGang.EnableWindow(TRUE);
			//�滭�˿�
			for (BYTE j=0;j<4;j++)
			{
				g_CardResource.m_ImageTableBottom.DrawCardItem(&BufferDC,m_cbGangCard[i],j*26+12,nYPos+5);
			}

			//�滭�߿�
			if (cbCurrentItem==m_cbCurrentItem)
			{
				BufferDC.Draw3dRect(5,nYPos,rcClient.Width()-5*2,ITEM_HEIGHT,RGB(255,255,0),RGB(255,255,0));
			}

			//�滭��־
			int nItemWidth=m_ImageActionExplain.GetWidth()/7;
			int nItemHeight=m_ImageActionExplain.GetHeight();
			m_ImageActionExplain.BitBlt(BufferDC,126,nYPos+5,nItemWidth,nItemHeight,nItemWidth*3,0);

			//���ñ���
			cbCurrentItem++;
			nYPos+=ITEM_HEIGHT;
		}
		else
			break;
	}

	//�滭����
	dc.BitBlt(0,0,rcClient.Width(),rcClient.Height(),&BufferDC,0,0,SRCCOPY);

	//������Դ
	BufferDC.DeleteDC();
	BufferImage.DeleteObject();



	return;
}

//������Ϣ
int CControlWnd::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (__super::OnCreate(lpCreateStruct)==-1) return -1;

	//������ť
	CRect rcCreate(0,0,0,0);
//	m_btListen.Create(NULL,WS_CHILD|WS_VISIBLE,rcCreate,this,IDC_LISTEN);
	m_btGiveUp.Create(NULL,WS_CHILD|WS_CLIPCHILDREN|WS_VISIBLE,rcCreate,this,IDC_GIVEUP);
	m_btChiHu.Create(NULL,WS_CHILD|WS_CLIPCHILDREN|WS_VISIBLE,rcCreate,this,IDC_CHIHU);
	
	m_btChiShang.Create(NULL,WS_CHILD|WS_CLIPCHILDREN/*|WS_VISIBLE*/,rcCreate,this,IDC_CHI_SHANG);
	m_btChiZhong.Create(NULL,WS_CHILD|WS_CLIPCHILDREN/*|WS_VISIBLE*/,rcCreate,this,IDC_CHI_ZHONG);
	m_btChiXia.Create(NULL,WS_CHILD|WS_CLIPCHILDREN/*|WS_VISIBLE*/,rcCreate,this,IDC_CHI_XIA);
	m_btPeng.Create(NULL,WS_CHILD|WS_CLIPCHILDREN/*|WS_VISIBLE*/,rcCreate,this,IDC_PENG);
	m_btGang.Create(NULL,WS_CHILD|WS_CLIPCHILDREN/*|WS_VISIBLE*/,rcCreate,this,IDC_GANG);

	//����λͼ
	m_btChiHu.SetButtonImage(IDB_BT_HU,AfxGetInstanceHandle(),false,false);
//	m_btListen.SetButtonImage(IDB_BT_LISTEN,AfxGetInstanceHandle(),false);
	m_btGiveUp.SetButtonImage(IDB_BT_QUXIAO,AfxGetInstanceHandle(),false,false);

	m_btChiShang.SetButtonImage(IDB_BT_CHI_SHANG,AfxGetInstanceHandle(),false,false);
	m_btChiZhong.SetButtonImage(IDB_BT_CHI_ZHONG,AfxGetInstanceHandle(),false,false);
	m_btChiXia.SetButtonImage(IDB_BT_CHI_XIA,AfxGetInstanceHandle(),false,false);
	m_btPeng.SetButtonImage(IDB_BT_PENG,AfxGetInstanceHandle(),false,false);
	m_btGang.SetButtonImage(IDB_BT_GANG,AfxGetInstanceHandle(),false,false);

	/*m_btChiShang SetMessageType(SKBM_MOUSEMOVE|SKBM_MOUSELEAVE);
	m_btChiZhong.SetMessageType(SKBM_MOUSEMOVE|SKBM_MOUSELEAVE);
	m_btChiXia.SetMessageType(SKBM_MOUSEMOVE|SKBM_MOUSELEAVE);*/


	//CBitmap bmp;
	//if(bmp.LoadBitmap(IDB_CONTROL))
	//{
	//	HRGN rgn;
	//	rgn = BitmapToRegion((HBITMAP)bmp, RGB(255, 0, 255));
	//	SetWindowRgn(rgn, TRUE);
	//	bmp.DeleteObject();
	//}

	return 0;
}

//�����Ϣ
void CControlWnd::OnLButtonDown(UINT nFlags, CPoint Point)
{
	__super::OnLButtonDown(nFlags, Point);

	//�����ж�
	if (m_cbCurrentItem!=0xFF)
	{
		//��������
		BYTE cbIndex=0;
		BYTE cbItemKind[4]={WIK_LEFT,WIK_CENTER,WIK_RIGHT,WIK_PENG};

		//��������
		for (BYTE i=0;i<CountArray(cbItemKind);i++)
		{
			if (((m_cbActionMask&cbItemKind[i])!=0)&&(m_cbCurrentItem==cbIndex++))
			{
				CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,cbItemKind[i],m_cbCenterCard);
				return;
			}
		}

		//��������
		for (BYTE i=0;i<CountArray(m_cbGangCard);i++)
		{
			if ((m_cbGangCard[i]!=0)&&(m_cbCurrentItem==cbIndex++))
			{
				CGameFrameView::GetInstance()->PostEngineMessage(IDM_CARD_OPERATE,WIK_GANG,m_cbGangCard[i]);
				return;
			}
		}

		//�������
		ASSERT(FALSE);
	}

	return;
}

//�����Ϣ
BOOL CControlWnd::OnSetCursor(CWnd * pWnd, UINT nHitTest, UINT uMessage)
{
	//λ�ò���
	if (m_cbItemCount!=0)
	{
		//��ȡλ��
		CRect rcClient;
		CPoint MousePoint;
		GetClientRect(&rcClient);
		GetCursorPos(&MousePoint);
		ScreenToClient(&MousePoint);
		
		//��������
		BYTE bCurrentItem=0xFF;
		CRect rcItem(5,CONTROL_TOP,rcClient.Width()-5*2,ITEM_HEIGHT*m_cbItemCount+CONTROL_TOP);

		if (rcItem.PtInRect(MousePoint))
			bCurrentItem=(BYTE)((MousePoint.y-CONTROL_TOP)/ITEM_HEIGHT);

		//��������
		if (m_cbCurrentItem!=bCurrentItem)
		{
			Invalidate();
			m_cbCurrentItem=bCurrentItem;
		}

		//���ù��
		if (m_cbCurrentItem!=0xFF)
		{
			SetCursor(LoadCursor(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDC_CARD_CUR)));
			return TRUE;
		}
	}

	return __super::OnSetCursor(pWnd,nHitTest,uMessage);
}

HBRUSH CControlWnd::OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor)
{
	HBRUSH hbr = CWnd::OnCtlColor(pDC, pWnd, nCtlColor);

	// TODO:  ���Ĭ�ϵĲ������軭�ʣ��򷵻���һ������
	return hbr;
}

HRGN CControlWnd::BitmapToRegion(HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance)
{
	HRGN hRgn = NULL;

	if (hBmp)
	{
		HDC hMemDC = CreateCompatibleDC(NULL);
		if (hMemDC)
		{
			BITMAP bm;
			GetObject(hBmp, sizeof(bm), &bm);

			//����һ��32λɫ��λͼ����ѡ���ڴ��豸����
			BITMAPINFOHEADER RGB32BITSBITMAPINFO = {
				sizeof(BITMAPINFOHEADER),		// biSize 
				bm.bmWidth,					// biWidth; 
				bm.bmHeight,				// biHeight; 
				1,							// biPlanes; 
				32,							// biBitCount 
				BI_RGB,						// biCompression; 
				0,							// biSizeImage; 
				0,							// biXPelsPerMeter; 
				0,							// biYPelsPerMeter; 
				0,							// biClrUsed; 
				0							// biClrImportant; 
			};
			VOID * pbits32; 
			HBITMAP hbm32 = CreateDIBSection(hMemDC,(BITMAPINFO *)&RGB32BITSBITMAPINFO, DIB_RGB_COLORS, &pbits32, NULL, 0);
			if (hbm32)
			{
				HBITMAP holdBmp = (HBITMAP)SelectObject(hMemDC, hbm32);

				// Create a DC just to copy the bitmap into the memory DC
				HDC hDC = CreateCompatibleDC(hMemDC);
				if (hDC)
				{
					// Get how many bytes per row we have for the bitmap bits (rounded up to 32 bits)
					BITMAP bm32;
					GetObject(hbm32, sizeof(bm32), &bm32);
					while (bm32.bmWidthBytes % 4)
						bm32.bmWidthBytes++;

					// Copy the bitmap into the memory DC
					HBITMAP holdBmp = (HBITMAP)SelectObject(hDC, hBmp);
					BitBlt(hMemDC, 0, 0, bm.bmWidth, bm.bmHeight, hDC, 0, 0, SRCCOPY);

					// For better performances, we will use the ExtCreateRegion() function to create the
					// region. This function take a RGNDATA structure on entry. We will add rectangles by
					// amount of ALLOC_UNIT number in this structure.
#define ALLOC_UNIT	100
					DWORD maxRects = ALLOC_UNIT;
					HANDLE hData = GlobalAlloc(GMEM_MOVEABLE, sizeof(RGNDATAHEADER) + (sizeof(RECT) * maxRects));
					RGNDATA *pData = (RGNDATA *)GlobalLock(hData);
					pData->rdh.dwSize = sizeof(RGNDATAHEADER);
					pData->rdh.iType = RDH_RECTANGLES;
					pData->rdh.nCount = pData->rdh.nRgnSize = 0;
					SetRect(&pData->rdh.rcBound, MAXLONG, MAXLONG, 0, 0);

					// Keep on hand highest and lowest values for the "transparent" pixels
					BYTE lr = GetRValue(cTransparentColor);
					BYTE lg = GetGValue(cTransparentColor);
					BYTE lb = GetBValue(cTransparentColor);
					BYTE hr = min(0xff, lr + GetRValue(cTolerance));
					BYTE hg = min(0xff, lg + GetGValue(cTolerance));
					BYTE hb = min(0xff, lb + GetBValue(cTolerance));

					// Scan each bitmap row from bottom to top (the bitmap is inverted vertically)
					BYTE *p32 = (BYTE *)bm32.bmBits + (bm32.bmHeight - 1) * bm32.bmWidthBytes;
					for (int y = 0; y < bm.bmHeight; y++)
					{
						// Scan each bitmap pixel from left to right
						for (int x = 0; x < bm.bmWidth; x++)
						{
							// Search for a continuous range of "non transparent pixels"
							int x0 = x;
							LONG *p = (LONG *)p32 + x;
							while (x < bm.bmWidth)
							{
								BYTE b = GetRValue(*p);
								if (b >= lr && b <= hr)
								{
									b = GetGValue(*p);
									if (b >= lg && b <= hg)
									{
										b = GetBValue(*p);
										if (b >= lb && b <= hb)
											// This pixel is "transparent"
											break;
									}
								}
								p++;
								x++;
							}

							if (x > x0)
							{
								// Add the pixels (x0, y) to (x, y+1) as a new rectangle in the region
								if (pData->rdh.nCount >= maxRects)
								{
									GlobalUnlock(hData);
									maxRects += ALLOC_UNIT;
									hData = GlobalReAlloc(hData, sizeof(RGNDATAHEADER) + (sizeof(RECT) * maxRects), GMEM_MOVEABLE);
									pData = (RGNDATA *)GlobalLock(hData);
								}
								RECT *pr = (RECT *)&pData->Buffer;
								SetRect(&pr[pData->rdh.nCount], x0, y, x, y+1);
								if (x0 < pData->rdh.rcBound.left)
									pData->rdh.rcBound.left = x0;
								if (y < pData->rdh.rcBound.top)
									pData->rdh.rcBound.top = y;
								if (x > pData->rdh.rcBound.right)
									pData->rdh.rcBound.right = x;
								if (y+1 > pData->rdh.rcBound.bottom)
									pData->rdh.rcBound.bottom = y+1;
								pData->rdh.nCount++;

								// On Windows98, ExtCreateRegion() may fail if the number of rectangles is too
								// large (ie: > 4000). Therefore, we have to create the region by multiple steps.
								if (pData->rdh.nCount == 2000)
								{
									HRGN h = ExtCreateRegion(NULL, sizeof(RGNDATAHEADER) + (sizeof(RECT) * maxRects), pData);
									if (hRgn)
									{
										CombineRgn(hRgn, hRgn, h, RGN_OR);
										DeleteObject(h);
									}
									else
										hRgn = h;
									pData->rdh.nCount = 0;
									SetRect(&pData->rdh.rcBound, MAXLONG, MAXLONG, 0, 0);
								}
							}
						}

						// Go to next row (remember, the bitmap is inverted vertically)
						p32 -= bm32.bmWidthBytes;
					}

					// Create or extend the region with the remaining rectangles
					HRGN h = ExtCreateRegion(NULL, sizeof(RGNDATAHEADER) + (sizeof(RECT) * maxRects), pData);
					if (hRgn)
					{
						CombineRgn(hRgn, hRgn, h, RGN_OR);
						DeleteObject(h);
					}
					else
						hRgn = h;

					// Clean up
					GlobalFree(hData);
					SelectObject(hDC, holdBmp);
					DeleteDC(hDC);
				}				
				DeleteObject(SelectObject(hMemDC, holdBmp));
			}			
			DeleteDC(hMemDC);
		}
	}	
	return hRgn;	
}

BOOL CControlWnd::PreTranslateMessage(MSG* pMsg)
{
	if(pMsg->message==WM_USER+10000)
	{
		if(m_cardControl)//�뿪ĳ����ť
			m_cardControl->SetShootCard();
		CSkinButton *pButton=(CSkinButton *)pMsg->wParam;//��ť����

		BYTE cbCard[3]={0,0,0};
		if(pMsg->lParam==1 && m_cardControl)
		{
			BYTE cbExcursion[3]={0,1,2};
			BYTE cbItemKind[4]={WIK_LEFT,WIK_CENTER,WIK_RIGHT};
			CSkinButton *pBtChi[3]={&m_btChiShang,&m_btChiZhong,&m_btChiXia};

			//�滭�˿�
			for (BYTE i=0;i<CountArray(cbItemKind);i++)
			{
				cbCard[0]=cbCard[1]=cbCard[3]=0;
				int p=0;
				if ((m_cbActionMask&cbItemKind[i])!=0)
				{
					//�滭�˿�
					for (BYTE j=0;j<3;j++)
					{
						BYTE cbCardData=m_cbCenterCard;
						if ((BAIBAN_CARD_DATA == m_cbCenterCard) && (CCardControl::m_byGodsData>0))
						{
							cbCardData = CCardControl::m_byGodsData;
						}
						cbCardData=cbCardData+j-cbExcursion[i];

						// �װ屾����Ҫ��ԭ
						if (cbCardData == CCardControl::m_byGodsData)
						{
							cbCardData = BAIBAN_CARD_DATA;
						}
						if(cbCardData!=m_cbCenterCard)
							cbCard[p++]=cbCardData;
					}

					if(pButton==pBtChi[i])
						m_cardControl->SetShootCard(cbCard[0],cbCard[1]);
				}
			}
		}
		return TRUE;
	}

	return CWnd::PreTranslateMessage(pMsg);
}

//////////////////////////////////////////////////////////////////////////
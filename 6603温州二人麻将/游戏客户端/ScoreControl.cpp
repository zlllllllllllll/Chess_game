#include "StdAfx.h"
#include "GameClient.h"
#include "ScoreControl.h"
#include ".\scorecontrol.h"

//////////////////////////////////////////////////////////////////////////

//��ť��ʶ
#define IDC_CLOSE_SCORE				100									//�رճɼ�

//////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CScoreControl, CWnd)
	ON_WM_PAINT()
	ON_WM_TIMER()
	ON_WM_CREATE()
	ON_WM_ERASEBKGND()
	ON_WM_LBUTTONDOWN()
	ON_BN_CLICKED(IDC_CLOSE_SCORE, OnBnClickedClose)
	ON_WM_NCDESTROY()
	ON_WM_MOVE()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////////

//���캯��
CScoreControl::CScoreControl()
{
	//���ñ���
	m_cbWeaveCount=0;
	ZeroMemory(&m_ScoreInfo,sizeof(m_ScoreInfo));

	//������Դ
	HINSTANCE hResInstance=AfxGetInstanceHandle();
	m_ImageWin.LoadFromResource(hResInstance,IDB_SCORE_WIN);
	m_ImageDraw.LoadFromResource(hResInstance,IDB_SCORE_DRAW);
	m_ImageGameScore.LoadFromResource(hResInstance,IDB_GAME_SCORE);
	m_ImageGameScoreFlag.LoadFromResource(hResInstance,IDB_GAME_SCORE_FLAG);

	//���ÿؼ�
	for (BYTE i=0;i<CountArray(m_WeaveCard);i++) m_WeaveCard[i].SetDirection(Direction_South);

	return;
}

//��������
CScoreControl::~CScoreControl()
{
}

//��λ����
void CScoreControl::RestorationData()
{
	//���ñ���
	m_cbWeaveCount=0;
	ZeroMemory(&m_ScoreInfo,sizeof(m_ScoreInfo));

	//���ش���
	if (m_hWnd!=NULL) ShowWindow(SW_HIDE);

	return;
}

//���û���
void CScoreControl::SetScoreInfo(const tagScoreInfo & ScoreInfo, const tagWeaveInfo & WeaveInfo,WORD dwMeUserID)
{
	//���ñ���
	m_ScoreInfo=ScoreInfo;
	m_cbWeaveCount=WeaveInfo.cbWeaveCount;
	m_dwMeUserID=dwMeUserID;

	//��ϱ���
	for (BYTE i=0;i<m_cbWeaveCount;i++)
	{
		bool bPublicWeave=(WeaveInfo.cbPublicWeave[i]==TRUE);
		m_WeaveCard[i].SetCardData(WeaveInfo.cbCardData[i],WeaveInfo.cbCardCount[i]);
		m_WeaveCard[i].SetDisplayItem(true);
	}

	//��ʾ����
	ShowWindow(SW_SHOW);

	return;
}

//�رհ�ť
void CScoreControl::OnBnClickedClose()
{
	//���ش���
	RestorationData();

	return;
}

int CScoreControl::GetHardSoftHu()
{
	//������Ϣ
	DWORD dwCardKind[]={CHK_PENG_PENG,CHK_QI_XIAO_DUI,CHK_SHI_SAN_YAO,CHK_YING_PAI,CHK_SAN_GODS,CHK_BA_DUI,CHK_YING_BA_DUI};


	int iChiType=0;
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//�û�����
		if (m_ScoreInfo.dwChiHuKind[i]==CHK_NULL) continue;

		//������Ϣ
		for (BYTE j=0;j<CountArray(dwCardKind);j++)
		{
			if (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j])
			{
				if (CHK_BA_DUI == (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j]))
				{
					if (CHK_YING_BA_DUI == (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j+1]))
					{
						continue;
					}					
				}
				iChiType|=dwCardKind[j];
				break;
			}
		}
		if(iChiType==0)
		{
			if(m_ScoreInfo.wProvideUser==i)
				iChiType=2;
			else
				iChiType=1;//���
		}
		else if(iChiType & CHK_YING_PAI)
			iChiType=2;//Ӳ��
		else if((iChiType & CHK_YING_BA_DUI)|| (iChiType&CHK_SAN_GODS))
			iChiType=3;//˫��
		else
			iChiType=0;
		break;
	}
	
	return iChiType;
}
//�ػ�����
void CScoreControl::OnPaint()
{
	CPaintDC dc(this);

	//��ȡλ��
	CRect rcClient;
	GetClientRect(&rcClient);

	//��������
	CFont InfoFont;
	//InfoFont.CreatePointFont(110,TEXT("����"),&dc);
	InfoFont.CreateFont(-16,0,0,0,FW_BOLD,0,0,0,134,3,2,1,2,TEXT("����"));

	//��������
	CDC DCBuffer;
	CBitmap ImageBuffer;
	DCBuffer.CreateCompatibleDC(&dc);
	ImageBuffer.CreateCompatibleBitmap(&dc,rcClient.Width(),rcClient.Height());

	//���� DC
	DCBuffer.SetBkMode(TRANSPARENT);
	DCBuffer.SelectObject(&ImageBuffer);
	//DCBuffer.SetTextColor(RGB(0,0,0));
	//DCBuffer.SelectObject(CSkinResourceManager::GetDefaultFont());
	//���� DC
	DCBuffer.SelectObject(InfoFont);
	DCBuffer.SetTextColor(RGB(0,0,0));

	//������Դ
	//CImageHandle HandleWin(&m_ImageWin);
	//CImageHandle HandleDraw(&m_ImageDraw);
	//CImageHandle HandleGameScoreFlag(&m_ImageGameScoreFlag);

	//�滭����
	m_ImageGameScore.Draw(DCBuffer.GetSafeHdc(),0,0);
	//�滭�˿�
	if(m_ScoreInfo.lGameScore[m_dwMeUserID]<0L)
	{

		//λ�ñ���
		int nCardSpace=2;
		int nItemWidth=g_CardResource.m_ImageTableBottom.GetViewWidth();
		int nTotalWidth=m_cbWeaveCount*(nItemWidth*3+nCardSpace)+nItemWidth*m_ScoreInfo.cbCardCount+nCardSpace;

		//����λ��
		int nYCardPos=79;
		int nXCardPos=(m_ImageGameScore.GetWidth()-nTotalWidth)/2;

		//�滭���
		for (BYTE i=0;i<m_cbWeaveCount;i++)
		{
			//�滭�˿�
			m_WeaveCard[i].DrawCardControl(&DCBuffer,nXCardPos,nYCardPos);

			//����λ��
			nXCardPos+=(nCardSpace+nItemWidth*3);
		}

		nXCardPos += 3;
		for (BYTE i=0;i<m_ScoreInfo.cbCardCount;i++)
		{
			//�滭�˿�
			int nXCurrentPos=nXCardPos;
			int nYCurrentPos=nYCardPos-g_CardResource.m_ImageTableBottom.GetViewHeight()-5;
			g_CardResource.m_ImageTableBottom.DrawCardItem(&DCBuffer,m_ScoreInfo.cbCardData[i],nXCurrentPos,nYCurrentPos);

			//����λ��
			nXCardPos+=nItemWidth;
			if ((i+2)==m_ScoreInfo.cbCardCount)
			{
				nXCardPos+=nCardSpace + 3;
			}
		}
	}

	//�滭����
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//�û�����
		if (m_ScoreInfo.dwChiHuKind[i]==CHK_NULL) continue;

		//������Ϣ
		DWORD dwCardKind[]={CHK_PENG_PENG,CHK_QI_XIAO_DUI,CHK_SHI_SAN_YAO,CHK_YING_PAI,CHK_SAN_GODS,CHK_BA_DUI,CHK_YING_BA_DUI};
		DWORD dwCardRight[]={CHR_DI,CHR_TIAN,CHR_QING_YI_SE,CHR_QIANG_GANG,CHK_QUAN_QIU_REN};

		//������Ϣ
		CString strCardInfo=TEXT("");
		LPCTSTR pszCardKind[]={TEXT("������"),TEXT("��С��"),TEXT("ʮ����"),TEXT("Ӳ��"),TEXT("������"),TEXT("�˶�"),TEXT("Ӳ�˶�")};
		LPCTSTR pszCardRight[]={TEXT("�غ�"),TEXT("���"),TEXT("��һɫ"),TEXT("�ܺ�"),TEXT("ȫ����")};

		//������Ϣ
		for (BYTE j=0;j<CountArray(dwCardKind);j++)
		{
			if (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j])
			{
				if (CHK_BA_DUI == (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j]))
				{
					if (CHK_YING_BA_DUI == (m_ScoreInfo.dwChiHuKind[i]&dwCardKind[j+1]))
					{
						continue;
					}					
				}
				strCardInfo=pszCardKind[j];
				break;
			}
		}
		if (strCardInfo.IsEmpty())
		{
			if(m_ScoreInfo.wProvideUser==i)
				strCardInfo = TEXT("Ӳ��");
			else
				strCardInfo = TEXT("���");
		}
		CRect rcCardKind(125,100,175,116);//�޸�175-375
		DCBuffer.DrawText(strCardInfo,rcCardKind,DT_SINGLELINE|DT_END_ELLIPSIS|DT_VCENTER);
		//��Ȩ��Ϣ
		strCardInfo="";
		for (BYTE j=0;j<CountArray(dwCardRight);j++)
		{
			if (m_ScoreInfo.dwChiHuRight[i]&dwCardRight[j])
			{
				if (CHR_QIANG_GANG == (m_ScoreInfo.dwChiHuRight[i]&dwCardRight[j]))
				{
					continue ;
				}
				strCardInfo=pszCardRight[j];
				break;
			}
		}
		if (strCardInfo.IsEmpty())
		{
			strCardInfo = TEXT("��ͨ");
		}

		//�滭��Ϣ
		CRect rcCardInfo(355,100,405,116);
		DCBuffer.DrawText(strCardInfo,rcCardInfo,DT_SINGLELINE|DT_END_ELLIPSIS);

		break;
	}


	//������Ϣ
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//��������
		TCHAR szUserScore[16]=TEXT("");
		_sntprintf(szUserScore,CountArray(szUserScore),TEXT("%I64d"),m_ScoreInfo.lGameScore[i]);

		//λ�ü���
		CRect rcName(135+i*140,123,135+140+i*140,160);

		CRect rcDingDi(123,165+i*30,158,165+(i+1)*30);
		CRect rcGods(181,165+i*30,236,165+(i+1)*30);
		CRect rcScore(160,215,320,230);//,165+i*30,302,165+(i+1)*30);
		CRect rcStatus(323,165+i*30,363,165+(i+1)*30);

		//�滭��Ϣ
		UINT nFormat=DT_SINGLELINE|DT_END_ELLIPSIS|DT_VCENTER;

		if(m_dwMeUserID==i)
		{
			DCBuffer.DrawText(szUserScore,lstrlen(szUserScore),&rcScore,nFormat);
			if(m_ScoreInfo.lGameScore[i]>0L)
			{//ʤ
				m_ImageWin.TransDrawImage(&DCBuffer,90,14,RGB(255,0,255));
			}
			if(m_ScoreInfo.lGameScore[i]<0L)
			{//��
				CString strInfo;
				strInfo.Format(_T("��ң�%s ���ˣ�"),m_ScoreInfo.szUserName[1-i]);
				DCBuffer.SetTextColor(RGB(255,255,58));
				CRect rcInfo(7,9,443,29);
				DCBuffer.DrawText(strInfo,&rcInfo,nFormat|DT_CENTER);
				DCBuffer.SetTextColor(RGB(0,0,0));
			}
			if(m_ScoreInfo.lGameScore[i]==0L)
			{//����
				m_ImageDraw.TransDrawImage(&DCBuffer,102,7,RGB(255,0,255));
			}
		}

		DCBuffer.DrawText(m_ScoreInfo.szUserName[i],lstrlen(m_ScoreInfo.szUserName[i]),&rcName,nFormat|DT_CENTER);

		//TCHAR szText[25]=TEXT("");
		//_sntprintf(szText,CountArray(szText),TEXT("%u"),m_ScoreInfo.byDingDi[i]);
		//DCBuffer.DrawText(szText,lstrlen(szText),&rcDingDi,nFormat|DT_CENTER);
		//_sntprintf(szText,CountArray(szText),TEXT("%I64d"),m_ScoreInfo.lGodsScore[i]);
		//DCBuffer.DrawText(szText,lstrlen(szText),&rcGods,nFormat|DT_CENTER);

		//ׯ�ұ�־
		if (m_ScoreInfo.wBankerUser==i)
		{
			//int nImageWidht=m_ImageGameScoreFlag.GetWidth();
			//int nImageHeight=m_ImageGameScoreFlag.GetHeight();
			//m_ImageGameScoreFlag.BlendDrawImage(&DCBuffer,395,168+i*30,RGB(255,0,255),240);
			if(m_ScoreInfo.byDingDi[i]>0)//���
				m_ImageGameScoreFlag.TransDrawImage(&DCBuffer,195+i*140,155,RGB(255,0,255));
		}
		else
		{
			if(m_ScoreInfo.byDingDi[i]>0)//����
				m_ImageGameScoreFlag.TransDrawImage(&DCBuffer,195+i*140,185,RGB(255,0,255));
		}
		
		////�û�״̬
		//if ((m_ScoreInfo.dwChiHuKind[i]!=0)&&((m_ScoreInfo.wProvideUser!=i)))
		//DCBuffer.DrawText(TEXT("����"),lstrlen(TEXT("����")),&rcStatus,nFormat|DT_CENTER);

		////�û�״̬
		//if ((m_ScoreInfo.wProvideUser==i)&&(m_ScoreInfo.dwChiHuKind[i]==0))
		//	DCBuffer.DrawText(TEXT("����"),lstrlen(TEXT("����")),&rcStatus,nFormat|DT_CENTER);

		////�û�״̬
		//if ((m_ScoreInfo.dwChiHuKind[i]!=0)&&((m_ScoreInfo.wProvideUser==i)))
		//DCBuffer.DrawText(TEXT("����"),lstrlen(TEXT("����")),&rcStatus,nFormat|DT_CENTER);



		//��Ӯ��־
		//int nImageWidht=m_ImageWinLose.GetWidth()/3;
		//int nImageHeight=m_ImageWinLose.GetHeight();

		////�滭��־
		//if(m_dwMeUserID==i)
		//{
		//	if(m_ScoreInfo.lGameScore[i]>0L)
		//	{//ʤ
		//		m_ImageWin.TransDrawImage(&DCBuffer,90,14,RGB(255,0,255));
		//	}
		//	if(m_ScoreInfo.lGameScore[i]<0L)
		//	{//��

		//	}
		//	if(m_ScoreInfo.lGameScore[i]==0L)
		//	{//����
		//		m_ImageDraw.TransDrawImage(&DCBuffer,102,7,RGB(255,0,255));
		//	}
		//	//int nImageExcursion=2*nImageWidht;
		//	//if (m_ScoreInfo.lGameScore[i]>0L) nImageExcursion=0;
		//	//if (m_ScoreInfo.lGameScore[i]<0L) nImageExcursion=nImageWidht;
		//	//m_ImageWinLose.BlendDrawImage(&DCBuffer,460,169+i*29,nImageWidht,nImageHeight,nImageExcursion,0,RGB(255,0,255),240);
		//}
	}
	//ʤ����������

	//�滭����
	dc.BitBlt(0,0,rcClient.Width(),rcClient.Height(),&DCBuffer,0,0,SRCCOPY);

	//������Դ
	DCBuffer.DeleteDC();
	InfoFont.DeleteObject();
	ImageBuffer.DeleteObject();

	return;
}

//�滭����
BOOL CScoreControl::OnEraseBkgnd(CDC * pDC)
{
	//���½���
	Invalidate(FALSE);
	UpdateWindow();

	return TRUE;
}

//��������
int CScoreControl::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (__super::OnCreate(lpCreateStruct)==-1) return -1;


	//���ô���
	SetWindowPos(NULL,0,0,m_ImageGameScore.GetWidth(),m_ImageGameScore.GetHeight(),SWP_NOZORDER|SWP_NOMOVE);
	CBitmap bmp;
	if(bmp.LoadBitmap(IDB_GAME_SCORE))
	{
		HRGN rgn;
		rgn = BitmapToRegion((HBITMAP)bmp, RGB(255, 0, 255));
		SetWindowRgn(rgn, TRUE);
		bmp.DeleteObject();
	}

	//������ť
	CRect rcCreate(0,0,0,0);
	m_btCloseScore.Create(NULL,WS_CHILD|WS_VISIBLE,rcCreate,this,IDC_CLOSE_SCORE);
	m_btCloseScore.SetButtonImage(IDB_BT_SCORE_CLOSE,AfxGetInstanceHandle(),false,false);

	//������ť
	CRect rcClient;
	GetClientRect(&rcClient);
	m_btCloseScore.SetWindowPos(NULL,178,250,0,0,SWP_NOSIZE|SWP_NOZORDER);

	return 0;
}

//�����Ϣ
void CScoreControl::OnLButtonDown(UINT nFlags, CPoint Point)
{
	__super::OnLButtonDown(nFlags,Point);

	//��Ϣģ��
	PostMessage(WM_NCLBUTTONDOWN,HTCAPTION,MAKELPARAM(Point.x,Point.y));

	return;
}

//////////////////////////////////////////////////////////////////////////


void CScoreControl::OnMove(int x, int y)
{
	__super::OnMove(x, y);

	//���½���
	Invalidate(FALSE);
	UpdateWindow();

}


HRGN CScoreControl::BitmapToRegion(HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance)
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

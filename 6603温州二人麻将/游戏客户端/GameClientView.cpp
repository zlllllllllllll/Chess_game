#include "StdAfx.h"
#include "Resource.h"
#include "GameClientView.h"
#include ".\gameclientview.h"
#include "GameClient.h"
#include <math.h>

//////////////////////////////////////////////////////////////////////////
//��ť��ʶ 

#define IDC_START						100								//��ʼ��ť
#define IDC_TRUSTEE_CONTROL				104								//�йܿ���
#define IDC_MAI_DI				        105								// ���
#define IDC_DING_DI				        106								// ����
#define IDC_MAI_CANCEL				    107								//�йܿ���
#define IDC_DING_CANCEL					108

//������ʶ
#define IDI_BOMB_EFFECT					101								//������ʶ
#define IDI_TIP_SINGLE					102
#define IDI_SIBO_PLAY                   220
//������Ŀ
#define BOMB_EFFECT_COUNT				12								//������Ŀ
#define DISC_EFFECT_COUNT				8								//����Ч��

#define PI  (3.141592653589793)
//////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CGameClientView, CGameFrameViewGDI)
	ON_WM_CREATE()
	ON_WM_SETCURSOR()
	ON_WM_LBUTTONDOWN()
	ON_BN_CLICKED(IDC_START, OnStart)
	ON_BN_CLICKED(IDC_TRUSTEE_CONTROL,OnStusteeControl)
	ON_BN_CLICKED(IDC_MAI_DI, OnMaiDi)
	ON_BN_CLICKED(IDC_DING_DI, OnDingDi)
	ON_BN_CLICKED(IDC_MAI_CANCEL, OnMaiCancel)
	ON_BN_CLICKED(IDC_DING_CANCEL,OnMaiCancel)
	ON_WM_TIMER()
	ON_WM_LBUTTONDBLCLK()
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////////

//���캯��
CGameClientView::CGameClientView()
{
	m_nXFace=48;
	m_nYFace=48;
	m_nXTimer=65;
	m_nYTimer=69;
	m_nXBorder=0;
	m_nYBorder=0;
	//��־����
	m_bOutCard=false;
	m_bWaitOther=false;
	m_bHuangZhuang=false;
	ZeroMemory(m_bListenStatus,sizeof(m_bListenStatus));

	//��Ϸ����
	m_lBaseScore=0L;
	m_wBankerUser=INVALID_CHAIR;
	m_wCurrentUser=INVALID_CHAIR;

	//��������
	m_bBombEffect=false;
	m_cbBombFrameIndex=0;

	//����Ч��
	m_wDiscUser=INVALID_CHAIR;
	m_cbDiscFrameIndex=0;

	//�û�״̬
	m_cbCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbUserAction,sizeof(m_cbUserAction));
	ZeroMemory(m_bTrustee,sizeof(m_bTrustee));
	ZeroMemory(m_szCenterText,sizeof(m_szCenterText));

	//����λͼ
	HINSTANCE hInstance=AfxGetInstanceHandle();
	m_ImageWait.LoadFromResource(hInstance,IDB_WAIT_TIP);
	m_ImageBack.LoadFromResource(hInstance,IDB_VIEW_BACK);
	m_ImageUserFlag.LoadFromResource(hInstance,IDB_USER_FLAG);
	//m_ImageOutCard.LoadFromResource(IDB_OUT_CARD_TIP,hInstance);
	m_ImageUserAction.LoadFromResource(hInstance,IDB_USER_ACTION);
	m_ImageActionBack.LoadFromResource(hInstance,IDB_ACTION_BACK);
	m_ImageCS.LoadFromResource(hInstance,IDB_CS_BACK);
	m_ImageHuangZhuang.LoadFromResource(hInstance,IDB_HUANG_ZHUANG);
	m_ImageListenStatusH.LoadFromResource(hInstance,IDB_LISTEN_FLAG_H);
	m_ImageListenStatusV.LoadFromResource(hInstance,IDB_LISTEN_FLAG_V);
	m_ImageTrustee.LoadImage(hInstance,TEXT("TRUSTEE"));
	m_ImageActionAni.LoadImage(AfxGetInstanceHandle(),TEXT("ActionAni"));
	//m_ImageDisc.LoadImage(AfxGetInstanceHandle(),TEXT("DISC"));
	m_ImageArrow.LoadImage(AfxGetInstanceHandle(),TEXT("ARROW"));
	m_ImageCenter.LoadFromResource(hInstance,IDB_VIEW_CENTER);
	m_ImageSaizi.LoadFromResource(hInstance,IDB_ANIM_SAIZI);

	m_ImageTipSingle.LoadFromResource(hInstance,IDB_TIP_SINGLE);


	ImageTimeBack.LoadFromResource(hInstance,IDB_TIME_BACK);
	ImageTimeNumber.LoadFromResource(hInstance,IDB_TIME_NUMBER);


	m_ImageDingMai.LoadFromResource(hInstance,IDB_DINGMAI);;						// ����
	m_ImageDingMaiFrame.LoadFromResource(hInstance,IDB_DINGMAI_FRAME);			// �����
	m_ImageNumber.LoadFromResource(hInstance,IDB_NUMBER);;				        // ����

	m_ImageReady.LoadFromResource(hInstance,IDB_READY);							//׼��

	m_byGodsData = 0x00;
	m_pGameClientDlg=CONTAINING_RECORD(this,CGameClientEngine,m_GameClientView);
	m_arBall.RemoveAll();
	m_iSicboAnimIndex = -1;                                                 // ���Ӷ�����ǰ֡
	ZeroMemory(m_bySicbo, sizeof(m_bySicbo));
	ZeroMemory(m_byDingMai, sizeof(m_byDingMai));
	m_SicboAnimPoint = CPoint(0,0);

	m_bTipSingle=false;
	m_bBankerCount = 1;
	return;
}

//��������
CGameClientView::~CGameClientView(void)
{
}

//������Ϣ
int CGameClientView::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (__super::OnCreate(lpCreateStruct)==-1) return -1;

	//��������
	enDirection Direction[]={Direction_North,Direction_East,Direction_South,Direction_West};
	//�û��˿�
	m_HeapCard[0].SetDirection(Direction[0]);
	m_HeapCard[0].SetGodsCard(0,0,0);
	//�û��˿�
	m_HeapCard[1].SetDirection(Direction[1]);
	m_HeapCard[1].SetGodsCard(0,0,0);
	//�û��˿�
	m_HeapCard[2].SetDirection(Direction[2]);
	m_HeapCard[2].SetGodsCard(0,0,0);
	//�û��˿�
	m_HeapCard[3].SetDirection(Direction[3]);
	m_HeapCard[3].SetGodsCard(0,0,0);
	
	//���ÿؼ�
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//�û��˿�
		m_TableCard[i].SetDirection(Direction[i*2]);
		m_DiscardCard[i].SetDirection(Direction[i*2]);		

		//����˿�
		m_WeaveCard[i][0].SetDisplayItem(true);
		m_WeaveCard[i][1].SetDisplayItem(true);
		m_WeaveCard[i][2].SetDisplayItem(true);
		m_WeaveCard[i][3].SetDisplayItem(true);
		m_WeaveCard[i][4].SetDisplayItem(true);
		m_WeaveCard[i][0].SetDirection(Direction[i*2]);
		m_WeaveCard[i][1].SetDirection(Direction[i*2]);
		m_WeaveCard[i][2].SetDirection(Direction[i*2]);
		m_WeaveCard[i][3].SetDirection(Direction[i*2]);
		m_WeaveCard[i][4].SetDirection(Direction[i*2]);
	}

	//���ÿؼ�
	m_UserCard[0].SetDirection(Direction_North);
	m_UserCard[1].SetDirection(Direction_East);


	//�����ؼ�
	CRect rcCreate(0,0,0,0);
	m_ScoreControl.Create(NULL,NULL,WS_CHILD|WS_CLIPCHILDREN|WS_CLIPSIBLINGS,rcCreate,this,200);
	m_ControlWnd.Create(NULL,NULL,WS_CHILD|WS_CLIPCHILDREN,rcCreate,this,10,NULL);
	m_ControlWnd.m_cardControl=&m_HandCardControl;
	//�û��˿�
	m_ControlWnd.SetSinkWindow(AfxGetMainWnd());
	//�����ؼ�
	m_btStart.Create(NULL,WS_CHILD|WS_CLIPCHILDREN,rcCreate,this,IDC_START);
	m_btStart.SetButtonImage(IDB_BT_START,AfxGetInstanceHandle(),false,false);

	//�йܰ�ť
	m_btStusteeControl.Create(TEXT(""),WS_CHILD|WS_DISABLED|WS_VISIBLE,rcCreate,this,IDC_TRUSTEE_CONTROL);
	m_btStusteeControl.SetButtonImage(IDB_BT_START_TRUSTEE,AfxGetInstanceHandle(),false,false);
//	m_btStusteeControl.ShowWindow(SW_HIDE);//�����й�

	m_btMaiDi.Create(TEXT(""),WS_CHILD|WS_DISABLED|WS_VISIBLE,rcCreate,this,IDC_MAI_DI);
	m_btMaiDi.SetButtonImage(IDB_BT_MAIDI,AfxGetInstanceHandle(),false,false);
	m_btDingDi.Create(TEXT(""),WS_CHILD|WS_DISABLED|WS_VISIBLE,rcCreate,this,IDC_DING_DI);
	m_btDingDi.SetButtonImage(IDB_BT_MAI_DINGDI,AfxGetInstanceHandle(),false,false);
	m_btMaiCancel.Create(TEXT(""),WS_CHILD|WS_DISABLED|WS_VISIBLE,rcCreate,this,IDC_MAI_CANCEL);
	m_btMaiCancel.SetButtonImage(IDB_BT_MAI_CANCEL,AfxGetInstanceHandle(),false,false);
	m_btDingCancel.Create(TEXT(""),WS_CHILD|WS_DISABLED|WS_VISIBLE,rcCreate,this,IDC_DING_CANCEL);
	m_btDingCancel.SetButtonImage(IDB_BT_DI_CANCEL,AfxGetInstanceHandle(),false,false);
	m_btMaiDi.ShowWindow(SW_HIDE);
	m_btDingDi.ShowWindow(SW_HIDE);
	m_btMaiCancel.ShowWindow(SW_HIDE);
	m_btDingCancel.ShowWindow(SW_HIDE);

	m_HandCardControl.pWnd=this;
//������Ƶ
//	for (WORD i=0;i<4;i++)
//	{
//		//������Ƶ
//		m_DlgVedioService[i].Create(NULL,NULL,WS_CHILD|WS_VISIBLE,rcCreate,this,300+i);
//		m_DlgVedioService[i].InitVideoService(i==2,true);
//
//		//������Ƶ
//		g_VedioServiceManager.SetVideoServiceControl(i,&m_DlgVedioService[i]);
//	}

	//SetTimer(IDI_DISC_EFFECT,250,NULL);

	return 0;
}

//���ý���
void CGameClientView::ResetGameView()
{
	//��־����
	m_bOutCard=false;
	m_bWaitOther=false;
	m_bHuangZhuang=false;
	ZeroMemory(m_bListenStatus,sizeof(m_bListenStatus));

	//��Ϸ����
	m_lBaseScore=0L;
	m_wBankerUser=INVALID_CHAIR;
	m_wCurrentUser=INVALID_CHAIR;

	//��������
	m_bBombEffect=false;
	m_cbBombFrameIndex=0;

	//����Ч��
	m_wDiscUser=INVALID_CHAIR;
	m_cbDiscFrameIndex=0;


	//�û�״̬
	m_cbCardData=0;
	m_byGodsData = 0x00;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbUserAction,sizeof(m_cbUserAction));
	ZeroMemory(m_szCenterText,sizeof(m_szCenterText));

	//��������
	m_btStart.ShowWindow(SW_HIDE);
	m_ControlWnd.ShowWindow(SW_HIDE);
	m_ScoreControl.RestorationData();
	m_btMaiDi.ShowWindow(SW_HIDE);
	m_btDingDi.ShowWindow(SW_HIDE);
	m_btMaiCancel.ShowWindow(SW_HIDE);
	m_btDingCancel.ShowWindow(SW_HIDE);
	
	//���ÿؼ�
	//m_btStusteeControl.EnableWindow(FALSE);


	//�˿�����
	m_UserCard[0].SetCardData(0,false);
	m_UserCard[1].SetCardData(0,false);
	m_HandCardControl.SetPositively(false);
	m_HandCardControl.SetDisplayItem(false);
	m_HandCardControl.SetCardData(NULL,0,0);

	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_HeapCard[i].SetCardData(0,0,0);
		m_HeapCard[i].SetGodsCard(0,0,0);
	}

	//�˿�����
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_TableCard[i].SetCardData(NULL,0);
		m_DiscardCard[i].SetCardData(NULL,0);
		m_WeaveCard[i][0].SetCardData(NULL,0);
		m_WeaveCard[i][1].SetCardData(NULL,0);
		m_WeaveCard[i][2].SetCardData(NULL,0);
		m_WeaveCard[i][3].SetCardData(NULL,0);
		m_WeaveCard[i][4].SetCardData(NULL,0);
	}

	//���ٶ�ʱ��
	KillTimer(IDI_DISC_EFFECT);
	KillTimer(IDI_BOMB_EFFECT);
	m_arBall.RemoveAll();
	m_iSicboAnimIndex = -1;                                                 // ���Ӷ�����ǰ֡
	ZeroMemory(m_bySicbo, sizeof(m_bySicbo));
	//m_SicboAnimPoint = CPoint(0,0);
	ZeroMemory(m_byDingMai, sizeof(m_byDingMai));
	return;
}

//�����ؼ�
VOID CGameClientView::RectifyControl(INT nWidth, INT nHeight)
{
	m_iSavedWidth=nWidth;
	m_iSavedHeight=nHeight;
	//��������
	m_ptReady[0].x=nWidth/2-33;
	m_ptReady[0].y=70;
	m_ptReady[1].x=nWidth/2-33;
	m_ptReady[1].y=nHeight-100;

	m_ptAvatar[0].x=nWidth/2-m_nXFace;
	m_ptAvatar[0].y=5+m_nYBorder;
	m_ptNickName[0].x=nWidth/2-50;
	m_ptNickName[0].y=20+m_nYBorder;
	m_ptClock[0].x=nWidth/2-m_nXFace-m_nXTimer-2;
	m_ptClock[0].y=17+m_nYBorder;

	
	m_UserFlagPos[0].x=m_ptNickName[0].x+100;//nWidth/2-m_nXFace-m_nXTimer-32;
	m_UserFlagPos[0].y=5+m_nYBorder;
	m_UserListenPos[0].x=nWidth/2;
	m_UserListenPos[0].y=m_nYBorder+100;
	m_PointTrustee[0].x=nWidth/2-m_nXFace-20-m_nXFace/2;
	m_PointTrustee[0].y=5+m_nYBorder;
	m_ptDingMai[0].x =m_ptNickName[0].x+160;// nWidth/2-m_nXFace-m_nXTimer + 40;
	m_ptDingMai[0].y = 21+m_nYBorder;

	m_ptAvatar[1].x=nWidth/2-m_nXFace;
	m_ptAvatar[1].y=nHeight-m_nYBorder-m_nYFace-5;
	m_ptNickName[1].x=nWidth/2-50;//+5+m_nXFace/2;
	m_ptNickName[1].y=nHeight-m_nYBorder-m_nYFace+8;
	m_ptClock[1].x=nWidth/2-m_nXFace/2-m_nXTimer-2;
	m_ptClock[1].y=nHeight-m_nYBorder-m_nYTimer-8+40;
	m_UserFlagPos[1].x=m_ptNickName[1].x+100;//nWidth/2-m_nXFace-m_nXTimer-32;
	m_UserFlagPos[1].y=nHeight-m_nYBorder-35;
	m_UserListenPos[1].x=nWidth/2;
	m_UserListenPos[1].y=nHeight-m_nYBorder-123;
	m_PointTrustee[1].x=nWidth/2-m_nXFace-20-m_nXFace/2;
	m_PointTrustee[1].y=nHeight-m_nYBorder-m_nYFace-5;
	m_ptDingMai[1].x = m_ptNickName[1].x+160;//nWidth/2-m_nXFace-m_nXTimer+40;
	m_ptDingMai[1].y = nHeight-m_nYBorder-20;

	m_SicboAnimPoint = CPoint(nWidth/2,nHeight/2);


	//�Է�����Ϸ�����У����е���
	m_UserCard[0].SetControlPoint(nWidth/2-210,m_nYBorder+m_nYFace+20);
	//�Լ�����Ϸ�����У����е���
	m_HandCardControl.SetBenchmarkPos(nWidth/2-20,nHeight-m_nYFace-m_nYBorder-20,enXCenter,enYBottom);

	//�����˿ˣ�����Ϸ��������ʾ����
	m_TableCard[0].SetControlPoint(nWidth/2-179,m_nYBorder+m_nYFace+20);	//�Է���
	m_TableCard[1].SetControlPoint(nWidth/2+330,nHeight-m_nYFace-m_nYBorder-20); //�Լ���

	//����˿�
	m_WeaveCard[0][0].SetControlPoint(nWidth/2+230,m_nYBorder+m_nYFace+20);
	m_WeaveCard[0][1].SetControlPoint(nWidth/2+155,m_nYBorder+m_nYFace+20);
	m_WeaveCard[0][2].SetControlPoint(nWidth/2+80,m_nYBorder+m_nYFace+20);
	m_WeaveCard[0][3].SetControlPoint(nWidth/2+5,m_nYBorder+m_nYFace+20);
	m_WeaveCard[0][4].SetControlPoint(nWidth/2-60,m_nYBorder+m_nYFace+20);

	//����˿�
	m_WeaveCard[1][0].SetControlPoint(nWidth/2-380,nHeight-m_nYFace-m_nYBorder-20);
	m_WeaveCard[1][1].SetControlPoint(nWidth/2-260,nHeight-m_nYFace-m_nYBorder-20);
	m_WeaveCard[1][2].SetControlPoint(nWidth/2-140,nHeight-m_nYFace-m_nYBorder-20);
	m_WeaveCard[1][3].SetControlPoint(nWidth/2-20,nHeight-m_nYFace-m_nYBorder-20);
	m_WeaveCard[1][4].SetControlPoint(nWidth/2+100,nHeight-m_nYFace-m_nYBorder-20);

	//�ѻ��˿�
	int nXCenter=nWidth/2;
	int nYCenter=nHeight/2-40;

	m_HeapCard[0].SetControlPoint(nXCenter-152,nYCenter-207);
	m_HeapCard[1].SetControlPoint(nXCenter+256,nYCenter-95);
	m_HeapCard[2].SetControlPoint(nXCenter-152,nYCenter+207);
	m_HeapCard[3].SetControlPoint(nXCenter-251,nYCenter-95);

	//�����˿�
	//m_DiscardCard[0].SetControlPoint(nXCenter-103,nYCenter-100);
	m_DiscardCard[0].SetControlPoint(nXCenter-158,nYCenter-100);
	//m_DiscardCard[2].SetControlPoint(nXCenter+100,nYCenter+112);
	m_DiscardCard[1].SetControlPoint(nXCenter+158,nYCenter+102);


	//���ƴ���
	m_ControlWnd.SetBenchmarkPos(nWidth-10,nHeight-m_nYBorder-180);


	//�ƶ���ť
	CRect rcButton;
	HDWP hDwp=BeginDeferWindowPos(6);
	m_btStart.GetWindowRect(&rcButton);
	const UINT uFlags=SWP_NOACTIVATE|SWP_NOZORDER|SWP_NOCOPYBITS|SWP_NOSIZE;

	//�ƶ�����
	DeferWindowPos(hDwp,m_btStart,NULL,(nWidth-rcButton.Width())/2,nHeight-120-m_nYBorder,0,0,uFlags);
	//�ƶ�����
	DeferWindowPos(hDwp,m_btStusteeControl,NULL,nWidth-m_nXBorder-(rcButton.Width()+5),nHeight-m_nYBorder-rcButton.Height()+5,0,0,uFlags);
	//�ƶ��ɼ�
	CRect rcScoreControl;
	m_ScoreControl.GetWindowRect(&rcScoreControl);
	DeferWindowPos(hDwp,m_ScoreControl,NULL,(nWidth-rcScoreControl.Width())/2,(nHeight-rcScoreControl.Height())*2/5,0,0,uFlags);

	m_btMaiDi.GetWindowRect(&rcButton);
	DeferWindowPos(hDwp,m_btMaiDi,NULL,(nWidth/2-rcButton.Width()-10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btDingDi,NULL,(nWidth/2-rcButton.Width()-10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btMaiCancel,NULL,(nWidth/2 + 10),nHeight-120-m_nYBorder,0,0,uFlags);
	DeferWindowPos(hDwp,m_btDingCancel,NULL,(nWidth/2 + 10),nHeight-120-m_nYBorder,0,0,uFlags);

	//��Ƶ����
//	CRect rcAVDlg;
//	m_DlgVedioService[0].GetWindowRect(&rcAVDlg);
//	DeferWindowPos(hDwp,m_DlgVedioService[1],NULL,nWidth-m_nXBorder-5-rcAVDlg.Width(),nHeight/2+30,0,0,uFlags);
//	DeferWindowPos(hDwp,m_DlgVedioService[3],NULL,m_nXBorder+5,nHeight/2+30,0,0,uFlags);
//	DeferWindowPos(hDwp,m_DlgVedioService[0],NULL,nWidth-m_nXBorder-5-rcAVDlg.Width(),5,0,0,uFlags);
//	m_DlgVedioService[2].GetWindowRect(&rcAVDlg);
//	DeferWindowPos(hDwp,m_DlgVedioService[2],NULL,m_nXBorder+5,nHeight-m_nYBorder-3-rcAVDlg.Height(),0,0,uFlags);

	//�����ƶ�
	EndDeferWindowPos(hDwp);
	return;
}


void CGameClientView::DrawUserTimerEx(CDC * pDC, int nXPos, int nYPos, WORD wTime)
{

	//ImageTimeNumber.LoadImage(AfxGetInstanceHandle(),TEXT("IDB_TIME_NUMBER"));//TEXT("TIME_NUMBER"));
	//CImageHandle ImageHandleBack(&ImageTimeBack);

	//CImageHandle ImageHandle(&ImageTimeNumber);
	//if (!ImageHandle.IsResourceValid())
	//	return;

	//��ȡ����
	const INT nNumberHeight=ImageTimeNumber.GetHeight();
	const INT nNumberWidth=ImageTimeNumber.GetWidth()/11;

	//������Ŀ
	LONG lNumberCount=2;
	WORD wNumberTemp=wTime;
	//do
	//{
	//	lNumberCount++;
	//	wNumberTemp/=10;
	//} while (wNumberTemp>0L);

	//λ�ö���
	INT nYDrawPos=nYPos-nNumberHeight/2+1;
	INT nXDrawPos=nXPos+(lNumberCount*nNumberWidth)/2-nNumberWidth;

	ImageTimeBack.TransDrawImage(pDC,nXDrawPos-30,nYDrawPos-10,RGB(255,0,255));
	//�滭����
	for (LONG i=0;i<lNumberCount;i++)
	{
		//�滭����
		WORD wCellNumber=wTime%10;
		ImageTimeNumber.TransDrawImage(pDC,nXDrawPos,nYDrawPos,nNumberWidth-5,nNumberHeight,wCellNumber*nNumberWidth,0,RGB(0,0,0));
		//m_ImageBack.TransDrawImage(pDesDC,0,0,iPartWidth,m_ImageBack.GetHeight(),iDrawPos,0,m_crTrans);

		//���ñ���
		wTime/=10;
		nXDrawPos-=nNumberWidth+1;
	};

}

//�滭����
void CGameClientView::DrawGameView(CDC * pDC, int nWidth, int nHeight)
{
	//�滭����
	DrawViewImage(pDC,m_ImageBack,DRAW_MODE_SPREAD);
	DrawViewImage(pDC,m_ImageCenter,DRAW_MODE_CENTENT);


	CString strScore1;
	strScore1.Format(_T("�Ƹ�:%d,%d"),nWidth,nHeight);
	//AfxMessageBox(strScore1);



	if (_tcslen(m_szCenterText) > 0)//��ʾ�ַ���
	{
		// ��������
		CFont font, *pOldFont=NULL;
		font.CreateFont(-20,0,0,0,700,0,0,0,134,3,2,1,2,TEXT("����"));
		pOldFont = pDC->SelectObject(&font);
		CRect rcText;
		rcText.left = nWidth/2-200;
		rcText.top = nHeight/2 - 100;
		rcText.right = rcText.left+400;
		rcText.bottom = rcText.top + 50;
		COLORREF oldClr = pDC->SetTextColor(RGB(255,255,255));
		DrawText(pDC,m_szCenterText, rcText, DT_SINGLELINE|DT_CENTER|DT_VCENTER|DT_END_ELLIPSIS);
		pDC->SetTextColor(oldClr);
		if (NULL != pOldFont)
		{
			pDC->SelectObject(pOldFont);
		}
	}

	//�û���־
	if (m_wBankerUser!=INVALID_CHAIR)
	{
		//����λͼ
		//CImageHandle ImageHandle(&m_ImageUserFlag);
		int nImageWidth=m_ImageUserFlag.GetWidth()/4;
		int nImageHeight=m_ImageUserFlag.GetHeight();
		//CImageHandle ImageHandleFrame(&m_ImageDingMaiFrame);
		int iFrameW = m_ImageDingMaiFrame.GetWidth();
		int iFrameH = m_ImageDingMaiFrame.GetHeight();

		//CImageHandle ImageHandleDM(&m_ImageDingMai);
		int iDingW = m_ImageDingMai.GetWidth()/2;
		int iDingH = m_ImageDingMai.GetHeight();


		//�滭��־
		for (WORD i=0;i<GAME_PLAYER;i++)
		{
			if (i == m_wBankerUser)
				m_ImageUserFlag.TransDrawImage(pDC,m_UserFlagPos[i].x-20,m_UserFlagPos[i].y,nImageWidth,nImageHeight,(m_bBankerCount-1)*nImageWidth,0,RGB(255,0,255));
			if(m_byDingMai[i]>0)
				m_ImageDingMai.TransDrawImage(pDC,m_ptDingMai[i].x-15-iDingW/2,m_ptDingMai[i].y-iDingH/2,RGB(255,0,255));
		}
	}

	//�����˿�
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_TableCard[i].DrawCardControl(pDC);		//�����齫���ڽ����Ժ����ʾ
		m_DiscardCard[i].DrawCardControl(pDC);		//�����齫
		m_WeaveCard[i][0].DrawCardControl(pDC);		//�������齫
		m_WeaveCard[i][1].DrawCardControl(pDC);		//�������齫
		m_WeaveCard[i][2].DrawCardControl(pDC);		//�������齫
		m_WeaveCard[i][3].DrawCardControl(pDC);		//�������齫
		m_WeaveCard[i][4].DrawCardControl(pDC);		//�������齫
	}

	//�ѻ��˿�
	m_HeapCard[0].DrawCardControl(pDC,_T(""));
	m_HeapCard[1].DrawCardControl(pDC,_T(""));
	m_HeapCard[2].DrawCardControl(pDC,_T(""));
	m_HeapCard[3].DrawCardControl(pDC,_T(""));

	//�û��˿�
	m_UserCard[0].DrawCardControl(pDC);			//�Է����е��齫����Ϸ��������ʾ
	m_HandCardControl.DrawCardControl(pDC);		//�Լ����е��齫����Ϸ��������ʾ


	//�ȴ���ʾ
	if (m_bWaitOther==true)
	{
		//CImageHandle HandleWait(&m_ImageWait);
		m_ImageWait.TransDrawImage(pDC,(nWidth-m_ImageWait.GetWidth())/2,nHeight-145,RGB(255,0,255));
	}

	//��ׯ��־
	if (m_bHuangZhuang==true)
	{
		//CImageHandle HandleHuangZhuang(&m_ImageHuangZhuang);
		m_ImageHuangZhuang.TransDrawImage(pDC,(nWidth-m_ImageHuangZhuang.GetWidth())/2,nHeight/2-103,RGB(255,0,255));
	}

	//���Ʊ�־
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		if (m_bListenStatus[i]==true)
		{
			//������Դ
			//CImageHandle HandleListenStatus(((i%2)==0)?&m_ImageListenStatusH:&m_ImageListenStatusV);

			if ((i%2)==0)
			{
				//��ȡ��Ϣ
				int nImageWidth=m_ImageListenStatusH.GetWidth();
				int nImageHeight=m_ImageListenStatusH.GetHeight();

				//�滭��־
				m_ImageListenStatusH.TransDrawImage(pDC,m_UserListenPos[i].x-nImageWidth/2,m_UserListenPos[i].y-nImageHeight/2-10,RGB(255,0,255));

			}
			else
			{
				//��ȡ��Ϣ
				int nImageWidth=m_ImageListenStatusV.GetWidth();
				int nImageHeight=m_ImageListenStatusV.GetHeight();

				//�滭��־
				m_ImageListenStatusV.TransDrawImage(pDC,m_UserListenPos[i].x-nImageWidth/2,m_UserListenPos[i].y-nImageHeight/2-10,RGB(255,0,255));

			}
			//��ȡ��Ϣ
		//	int nImageWidth=m_ImageListenStatusH->GetWidth();
		//	int nImageHeight=m_ImageListenStatusH->GetHeight();

		//	//�滭��־
		//	m_ImageListenStatusH->TransDrawImage(pDC,m_UserListenPos[i].x-nImageWidth/2,m_UserListenPos[i].y-nImageHeight/2-10,RGB(255,0,255));
		}
	}

	if(m_bTipSingle)
	{
		//CImageHandle HandleTip(&m_ImageTipSingle);
		m_ImageTipSingle.TransDrawImage(pDC,nWidth/2-m_ImageTipSingle.GetWidth()/2,nHeight/2+220,RGB(255,0,255));
	}
	//�û�״̬
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		if ((m_wOutCardUser==i)||(m_cbUserAction[i]!=0))
		{
			//����λ��
			int nXPos=0,nYPos=0;
			switch (i)
			{
			case 0:	//����
				{
					nXPos=nWidth/2-32;
					nYPos=m_nYBorder+95;
					break;
				}
			case 1:	//����
				{
					nXPos=nWidth/2-32;
					nYPos=nHeight-m_nYBorder-240;
					break;
				}
			}

			//�滭����
			if (m_cbUserAction[i]!=WIK_NULL)
			{	

				//�滭����
				if (m_bBombEffect==true && i==0)
				{
					int nXImagePos=-1;
					if (m_cbUserAction[i]&WIK_PENG) nXImagePos=59;
					else if (m_cbUserAction[i]&WIK_GANG) nXImagePos=118;
					else if (m_cbUserAction[i]&WIK_LISTEN) nXImagePos=-1;
					else if (m_cbUserAction[i]&WIK_CHI_HU) nXImagePos=-1;
					else nXImagePos=0;


					if(nXImagePos!=-1)
					{
					//��������
					//CImageHandle ImageHandle(&m_ImageActionBack);
					m_ImageActionBack.BlendDrawImage(pDC,nXPos,nYPos,m_ImageActionBack.GetWidth(),m_ImageActionBack.GetHeight(),
						0,0,RGB(255,255,255),180);
						m_ImageActionAni.DrawImage(pDC,nXPos+29,nYPos+29,59,65,nXImagePos,0,59,65);
					}
				}
			}
			else
			{	
				if(i==0)
				{
					//��������
					//CImageHandle ImageHandle(&m_ImageActionBack);
					m_ImageActionBack.BlendDrawImage(pDC,nXPos,nYPos,m_ImageActionBack.GetWidth(),m_ImageActionBack.GetHeight(),
							0,0,RGB(255,255,255),180);
					//�滭�˿�
					g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,m_cbCardData,nXPos+39,nYPos+29);

				}
				else
				{
					//��������
					//CImageHandle ImageHandle(&m_ImageActionBack);
					m_ImageActionBack.BlendDrawImage(pDC,nXPos,nYPos,m_ImageActionBack.GetWidth(),m_ImageActionBack.GetHeight(),
							0,0,RGB(255,255,255),180);
					//�滭�˿�
					g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,m_cbCardData,nXPos+39,nYPos+29);

				}
			}
		}
	}

	int nXPos=15,nYPos=10;
	//��������
	//CImageHandle ImageHandle(&m_ImageCS);
	m_ImageCS.BlendDrawImage(pDC,nXPos,nYPos,m_ImageCS.GetWidth(),m_ImageCS.GetHeight(),0,0,RGB(255,0,255),255);
	if (m_byGodsData>0)
	{
		//�滭�˿�
		g_CardResource.m_ImageUserBottom.DrawCardItem(pDC,m_byGodsData,nXPos+55,nYPos+13);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	HFONT hFont=CreateFont(-14,0,0,0,400,0,0,0,134,3,2,1,2,TEXT("����"));
	HFONT hOldFont=(HFONT)pDC->SelectObject(hFont);
	//�滭�û�
	pDC->SetTextColor(RGB(255,255,0));
	CString strScore;
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//��������
	//	IClientUserItem * pUserData=GetUserInfo(i);
		 IClientUserItem * pUserData=GetClientUserItem(i);
		if (pUserData!=NULL)
		{
			//�û�����
			pDC->SetTextAlign(TA_TOP|TA_RIGHT);
			//DrawTextString(pDC,pUserData->szNickName,RGB(255,255,255),RGB(0,0,0),m_ptNickName[i].x,m_ptNickName[i].y);
			//�滭����

			pDC->SetTextColor(RGB(255,255,255));
			TextOut(pDC,m_ptNickName[i].x,m_ptNickName[i].y,pUserData->GetNickName());

			pDC->SetTextAlign(TA_TOP|TA_LEFT);
			pDC->SetTextColor(RGB(255,255,0));
			strScore.Format(_T("�Ƹ�:%I64d"),pUserData->GetUserScore());
			TextOut(pDC,m_ptDingMai[i].x+30,m_ptNickName[i].y,strScore);

			//������Ϣ
			WORD wUserTimer=GetUserClock(i);
			if ((wUserTimer!=0)&&(m_wCurrentUser!=INVALID_CHAIR))
			{
				DrawUserTimerEx(pDC,nWidth/2,nHeight/2,wUserTimer);
				if(m_wCurrentUser==0)
					m_ImageArrow.DrawImage(pDC,nWidth/2-15,nHeight/2-m_ImageArrow.GetHeight()*2,m_ImageArrow.GetWidth()/4,m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4*m_wCurrentUser,0);
				if(m_wCurrentUser==1)
					m_ImageArrow.DrawImage(pDC,nWidth/2-15,nHeight/2+m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4,m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4*2,0);
			}
			if((wUserTimer!=0)&&(m_wCurrentUser==INVALID_CHAIR))
			{
				DrawUserTimerEx(pDC,nWidth/2,nHeight/2,wUserTimer);
				if(i==0)
					m_ImageArrow.DrawImage(pDC,nWidth/2-15,nHeight/2-m_ImageArrow.GetHeight()*2,m_ImageArrow.GetWidth()/4,m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4*i,0);
				if(i==1)
					m_ImageArrow.DrawImage(pDC,nWidth/2-15,nHeight/2+m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4,m_ImageArrow.GetHeight(),m_ImageArrow.GetWidth()/4*2,0);
			}

			if (pUserData->GetUserStatus()==US_READY) 
			{
				//CImageHandle ImageHandle(&m_ImageReady);
				m_ImageReady.TransDrawImage(pDC,m_ptReady[i].x,m_ptReady[i].y,RGB(255,0,255));
			}
		}
	}
	pDC->SelectObject(hOldFont);
	DrawSicboAnim(pDC);
	return;
}

//��������
void CGameClientView::SetBaseScore(__int64 lBaseScore)
{
	//�����˿�
	if (lBaseScore!=m_lBaseScore)
	{
		//���ñ���
		m_lBaseScore=lBaseScore;

		//���½���
		RefreshGameView();
	}

	return;
}

//�����˿�
void CGameClientView::SetHuangZhuang(bool bHuangZhuang)
{
	//�����˿�
	if (bHuangZhuang!=m_bHuangZhuang)
	{
		//���ñ���
		m_bHuangZhuang=bHuangZhuang;

		//���½���
		RefreshGameView();
	}

	return;
}

//ׯ���û�
void CGameClientView::SetBankerUser(WORD wBankerUser)
{
	//�����û�
	if (wBankerUser!=m_wBankerUser)
	{
		//���ñ���
		m_wBankerUser=wBankerUser;

		//���½���
		RefreshGameView();
	}

	return;
}

//״̬��־
void CGameClientView::SetStatusFlag(bool bOutCard, bool bWaitOther)
{
	//���ñ���
	m_bOutCard=bOutCard;
	m_bWaitOther=bWaitOther;

	//���½���
	RefreshGameView();

	return;
}

//������Ϣ
void CGameClientView::SetOutCardInfo(WORD wViewChairID, BYTE cbCardData)
{
	//���ñ���
	m_cbCardData=cbCardData;
	m_wOutCardUser=wViewChairID;

	//���½���
	RefreshGameView();

	return;
}

//������Ϣ
void CGameClientView::SetUserAction(WORD wViewChairID, BYTE bUserAction)
{
	//���ñ���
	if (wViewChairID<GAME_PLAYER)
	{
		m_cbUserAction[wViewChairID]=bUserAction;
		SetBombEffect(true);
	}
	else 
	{
		ZeroMemory(m_cbUserAction,sizeof(m_cbUserAction));
		if(m_bBombEffect)
			SetBombEffect(false);
	}

	RectifyControl(m_iSavedWidth,m_iSavedHeight);
	//���½���
	RefreshGameView();

	return;
}
//���Ʊ�־
void CGameClientView::SetUserListenStatus(WORD wViewChairID, bool bListenStatus)
{
	//���ñ���
	if (wViewChairID<GAME_PLAYER)
	{
		SetBombEffect(true);
		m_cbUserAction[wViewChairID]=WIK_LISTEN;
		m_bListenStatus[wViewChairID]=bListenStatus;
	}
	else 
		ZeroMemory(m_bListenStatus,sizeof(m_bListenStatus));

	//���½���
	RefreshGameView();

	return;
}
//���ö���
bool CGameClientView::SetBombEffect(bool bBombEffect)
{
	if (bBombEffect==true)
	{
		//���ñ���
		m_bBombEffect=true;
		m_cbBombFrameIndex=0;

		//����ʱ��
		SetTimer(IDI_BOMB_EFFECT,250,NULL);
	}
	else
	{
		//ֹͣ����
		if (m_bBombEffect==true)
		{
			//ɾ��ʱ��
			KillTimer(IDI_BOMB_EFFECT);

			//���ñ���
			m_bBombEffect=false;
			m_cbBombFrameIndex=0;

			//���½���
			RefreshGameView();
		}
	}

	return true;
}
//�����û�
void CGameClientView::SetDiscUser(WORD wDiscUser)
{
	if(m_wDiscUser != wDiscUser)
	{
		//���±���
		m_wDiscUser=wDiscUser;

		//���½���
		RefreshGameView();
	}
	return;
}
//��ʱ���
void CGameClientView::SetCurrentUser(WORD wCurrentUser)
{
	if (m_wCurrentUser != wCurrentUser)
	{
		//���±��� 
		m_wCurrentUser=wCurrentUser;
		
		//���½���
		RefreshGameView();
	}
	return;
}
//�����й�
void CGameClientView::SetTrustee(WORD wTrusteeUser,bool bTrustee)
{
	//У������ 
	ASSERT(wTrusteeUser>=0&&wTrusteeUser<GAME_PLAYER);

	if(m_bTrustee[wTrusteeUser] !=bTrustee)	
	{
		//��������
		m_bTrustee[wTrusteeUser]=bTrustee;

		//���½���
		RefreshGameView();
	}
	return;

}

// ������������
void CGameClientView::SetCenterText(LPCTSTR szText)
{
	if (NULL == szText)
	{
		ZeroMemory(&m_szCenterText, sizeof(m_szCenterText));
	}
	else
	{
		_sntprintf(m_szCenterText,sizeof(m_szCenterText), TEXT("%s"),szText);
	}
	RefreshGameView();
}

void CGameClientView::SetGodsCard(BYTE byGodsCard)
{
	m_byGodsData = byGodsCard;
	RefreshGameView();
}

BYTE CGameClientView::GetGodsCard()
{
	return m_byGodsData;
}

void CGameClientView::SetDingMaiValue(BYTE byDingMai[])
{
	if (NULL == byDingMai)
	{
		ZeroMemory(m_byDingMai, sizeof(m_byDingMai));
	}
	else
	{
		for (int i=0;i<GAME_PLAYER; ++i)
		{
			m_byDingMai[i] = byDingMai[i];
		}
	}	
	RefreshGameView();
}

// ��������
void CGameClientView::DrawTextString(CDC * pDC, LPCTSTR pszString, COLORREF crText, COLORREF crFrame, int nXPos, int nYPos)
{
	//��������
	int nStringLength=lstrlen(pszString);
	int nXExcursion[8]={1,1,1,0,-1,-1,-1,0};
	int nYExcursion[8]={-1,0,1,1,1,0,-1,-1};
	
	//�滭�߿�
	pDC->SetTextColor(crFrame);
	for (int i=0;i<CountArray(nXExcursion);i++)
	{
		TextOut(pDC,nXPos+nXExcursion[i],nYPos+nYExcursion[i],pszString,nStringLength);
	}

	//�滭����
	pDC->SetTextColor(crText);
	TextOut(pDC,nXPos,nYPos,pszString,nStringLength);

	return;
}

//�����Ϣ
BOOL CGameClientView::OnSetCursor(CWnd * pWnd, UINT nHitTest, UINT uMessage)
{
	//��ȡ���
	CPoint MousePoint;
	GetCursorPos(&MousePoint);
	ScreenToClient(&MousePoint);

	//�������
	bool bRePaint=false;
	bool bHandle=m_HandCardControl.OnEventSetCursor(MousePoint,bRePaint);

	//�ػ�����
	if (bRePaint==true)
		RefreshGameView();

	//������
	if (bHandle==false)
		__super::OnSetCursor(pWnd,nHitTest,uMessage);

	return TRUE;
}

//�����Ϣ
void CGameClientView::OnLButtonDown(UINT nFlags, CPoint Point)
{
	__super::OnLButtonDown(nFlags, Point);

	//��ȡ�˿�
	BYTE cbHoverCard=m_HandCardControl.GetHoverCard();
	if (cbHoverCard!=0) 
		SendEngineMessage(IDM_OUT_CARD,cbHoverCard,cbHoverCard);
	else
		SendEngineMessage(IDM_OUT_INVALID_CARD,0,0);


	return;
}

//��ʼ��ť
void CGameClientView::OnStart()
{
	m_bTipSingle=false;
	//������Ϣ
	SendEngineMessage(IDM_START,0,0);
	//BYTE cards[]=
	//{0x01,0x02,0x09,0x11,0x11,0x12,0x16,0x18,0x19,
	//0x23,0x24,0x26
	//};
	//m_HandCardControl.SetDisplayItem(true);
	//m_HandCardControl.SetGodsCard(0x21);
	//WORD wCount = sizeof(cards)/sizeof(cards[0]);
	//BYTE byOutIndex[]={27,28,29,30,31};
	//m_HandCardControl.SetOutCardData(byOutIndex, sizeof(byOutIndex));
	//m_HandCardControl.SetCardData(cards,wCount,0x37 );
	//m_HandCardControl.UpdateCardDisable(true);
	//RefreshGameView();
	//m_pGameClientDlg->SetGameStatus(GS_MJ_PLAY);
	//BYTE cards[2]={rand()%6 + 1, rand()%6+1};
	//StartSicboAnim(cards);
	return;
}
//�Ϲܿ���
void CGameClientView::OnStusteeControl()
{
	SendEngineMessage(IDM_TRUSTEE_CONTROL,0,0);
	return;
}

void CGameClientView::OnMaiDi()
{
	SendEngineMessage(IDM_DING_DI,2,0);  // ���
}
void CGameClientView::OnDingDi()
{
	SendEngineMessage(IDM_DING_DI,2,0);  // ����
}

void CGameClientView::OnMaiCancel()
{
	SendEngineMessage(IDM_DING_DI,1,0); // ȡ��
}

//////////////////////////////////////////////////////////////////////////
void CGameClientView::OnTimer(UINT nIDEvent)
{
	// TODO: Add your message handler code here and/or call default
	if(nIDEvent==IDI_TIP_SINGLE)
	{
		m_bTipSingle=false;
		KillTimer(IDI_TIP_SINGLE);
		RefreshGameView();
	}
	//��������
	if (nIDEvent==IDI_BOMB_EFFECT)
	{
		//ֹͣ�ж�
		if (m_bBombEffect==false)
		{
			KillTimer(IDI_BOMB_EFFECT);
			return;
		}

		//���ñ���
		if ((m_cbBombFrameIndex+1)>=BOMB_EFFECT_COUNT)
		{
			//ɾ��ʱ��
			KillTimer(IDI_BOMB_EFFECT);

			//���ñ���
			m_bBombEffect=false;
			m_cbBombFrameIndex=0;
		}
		else m_cbBombFrameIndex++;

		//���½���
		RefreshGameView();

		return;
	}
	if (nIDEvent==IDI_DISC_EFFECT)
	{
		//���ñ���
		if ((m_cbDiscFrameIndex+1)>=DISC_EFFECT_COUNT)
		{
			m_cbDiscFrameIndex=0;
		}
		else m_cbDiscFrameIndex++;

		//���½���
		RefreshGameView();

		return;

	}
	if (IDI_SIBO_PLAY == nIDEvent)
	{
		if (NULL == m_pGameClientDlg)
		{
			StopSicboAnim();
			return ;
		}

		if (GS_MJ_MAIDI != m_pGameClientDlg->GetGameStatus())
		{
			StopSicboAnim();
			return ;
		}

		// ���ƶ���
		m_iSicboAnimIndex ++;
		if (m_iSicboAnimIndex<13)
		{
			//��������
			if (NULL != m_pGameClientDlg && (m_iSicboAnimIndex<13)
				&& (0 == m_iSicboAnimIndex%5))
			{
				//if (m_pGameClientDlg->IsEnableSound())
				{
					//m_pGameClientDlg->PlayGameSound(AfxGetInstanceHandle(),TEXT("SICBO_WAV"));
				}
			}			
			OnEnterRgn(150);
		}

		if (m_iSicboAnimIndex > 20)
		{
			m_iSicboAnimIndex = -1;
			KillTimer(IDI_SIBO_PLAY);
			SendEngineMessage(IDM_DISPATCH_CARD,0,0);
		}
		if (m_iSicboAnimIndex > 13)
		{
			KillTimer(IDI_SIBO_PLAY);
			SetTimer(IDI_SIBO_PLAY, 100, NULL);
		}
		else if (m_iSicboAnimIndex >9)
		{
			KillTimer(IDI_SIBO_PLAY);
			SetTimer(IDI_SIBO_PLAY, 80, NULL);
		}
		else if (m_iSicboAnimIndex > 5)
		{
			KillTimer(IDI_SIBO_PLAY);
			SetTimer(IDI_SIBO_PLAY, 50, NULL);
		}
		else if (m_iSicboAnimIndex>1)
		{
			KillTimer(IDI_SIBO_PLAY);
			SetTimer(IDI_SIBO_PLAY, 20, NULL);
		}
		RefreshGameView();
		return ;
	}

	__super::OnTimer(nIDEvent);
}

void CGameClientView::OnLButtonDblClk(UINT nFlags, CPoint point)
{
	// TODO: �ڴ������Ϣ�����������/�����Ĭ��ֵ

	__super::OnLButtonDblClk(nFlags, point);
	CRect rect(0,0,200,200);
	if (rect.PtInRect(point))
	{
		//��Ҫȷ�����
		m_pGameClientDlg->SendSocketData(SUB_C_CHECK_SUPER);
	}
	
}

// �滭�����Ӷ���
void CGameClientView::DrawSicboAnim(CDC *pDC)
{
	if ((m_iSicboAnimIndex < 0) || (NULL == m_pGameClientDlg))
	{
		return ;
	}

	if (GS_MJ_MAIDI != m_pGameClientDlg->GetGameStatus())
	{
		return ;
	}
	if (m_iSicboAnimIndex > 0)
	{
		// �����Ӷ���
		//CImageHandle ImageHandleSaizi(&m_ImageSaizi);
		int nImageHeight=m_ImageSaizi.GetHeight();
		int nImageWidth=m_ImageSaizi.GetWidth()/21;
		for (int i=0; i<m_arBall.GetCount(); ++i)
		{
			BYTE byIndex = (BYTE)(m_arBall[i].iIndex%15+6);
			int iX = int(m_SicboAnimPoint.x+m_arBall[i].dbX-nImageWidth/2);
			int iY = int(m_SicboAnimPoint.y+m_arBall[i].dbY-nImageHeight/2);
			if (m_iSicboAnimIndex>13)
			{
				byIndex = m_bySicbo[i]-1;
			}
			m_ImageSaizi.TransDrawImage(pDC, iX,iY, nImageWidth, nImageHeight,byIndex *nImageWidth, 0,RGB(255,0,255));
		}
	}
}

void CGameClientView::OnEnterRgn(double dbR)
{
	// �߽練�� 
	for (int i=0; i<m_arBall.GetCount(); ++i)
	{
		// �Ƿ���Բ��
		CRect rect((int)-dbR, (int)-dbR, (int)+dbR, (int)+dbR);
		CPoint ptTemp((int)(m_arBall[i].dbX + m_arBall[i].dbDx),(int)(m_arBall[i].dbY + m_arBall[i].dbDy));
		//if ((m_arBall[i].dbX*m_arBall[i].dbX + m_arBall[i].dbY*m_arBall[i].dbY) > (dbR*dbR))
		if (!rect.PtInRect(ptTemp))
		{
			mcFanTang(m_arBall[i]);
			m_arBall[i].dbX += m_arBall[i].dbDx; 
			m_arBall[i].dbY += m_arBall[i].dbDy;
		}

		if ((m_arBall[i].dbX<-dbR + m_arBall[i].dbWidth/2 && m_arBall[i].dbDx<0)
			|| (m_arBall[i].dbX>dbR-m_arBall[i].dbWidth/2 && m_arBall[i].dbDx>0))
		{ 
			m_arBall[i].dbDx *= -1; 
		}

		if ((m_arBall[i].dbY<-dbR + m_arBall[i].dbHeight/2 && m_arBall[i].dbDy<0)
			|| (m_arBall[i].dbY>dbR-m_arBall[i].dbHeight/2 && m_arBall[i].dbDy>0))
		{ 
			m_arBall[i].dbDy *= -1; 
		}

		//�������MC֮���Ƿ�����ײ���о͸�������ı䡰���������� 
		for (int j = i+1; j<m_arBall.GetCount(); j++) 
		{ 
			if (myHitTest(m_arBall[i],m_arBall[j]))
			{
				mc12(m_arBall[i], m_arBall[j]); 
				m_arBall[i].dbX += m_arBall[i].dbDx; 
				m_arBall[j].dbX += m_arBall[j].dbDx; 
				m_arBall[i].dbY += m_arBall[i].dbDy; 
				m_arBall[j].dbY += m_arBall[j].dbDy; 
			} 
		}
		//�ƶ�һ����������
		m_arBall[i].dbX += m_arBall[i].dbDx; 
		m_arBall[i].dbY += m_arBall[i].dbDy;
		if ((fabs(m_arBall[i].dbDx) < 0.5) && (fabs(m_arBall[i].dbDy) < 0.5))
		{
			m_arBall[i].dbDx=1.6f;
			m_arBall[i].dbDy=2.7f;
		}
		++(m_arBall[i].iIndex);
	}
}

//��ײ����������������ײ����������˶�����ϳ��µ�����ֵ 
void CGameClientView::mc12(BALL &mc1, BALL& mc2)
{ 
	//��ײ�� 
	double  ang = atan2((mc2.dbY-mc1.dbY),mc2.dbX-mc1.dbX); 
	//�˶��� 
	double ang1 = atan2(mc1.dbDy,mc1.dbDx); 
	double ang2 = atan2(mc2.dbDy, mc2.dbDx);

	//����� 
	double _ang1 = 2*ang-ang1- PI; 
	double _ang2 = 2*ang-ang2-PI; 

	//�˶�ʸ�� 
	double r1=sqrt(mc1.dbDx*mc1.dbDx+mc1.dbDy*mc1.dbDy); 
	double r2=sqrt(mc2.dbDx*mc2.dbDx+mc2.dbDy*mc2.dbDy); 

	//��ײʸ�� 
	double a1 = (mc1.dbDy/sin(ang1))*cos(ang-ang1); 
	double a2 = (mc2.dbDy/sin(ang2))*cos(ang-ang2); 

	//��ײʸ���ϳ� 
	double dx1 = a1*cos(ang)+a2*cos(ang); 
	double dy1 = a1*sin(ang)+a2*sin(ang);

	//��ײ������� 
	mc1.dbDx = r1*cos((double)_ang1)+dx1; 
	mc1.dbDy = r1*sin((double)_ang1)+dy1; 
	mc2.dbDx = r2*cos((double)_ang2)+dx1; 
	mc2.dbDy = r2*sin((double)_ang2)+dy1;
} 


//��ײ��� 
bool CGameClientView::myHitTest(BALL &mc1, BALL& mc2)
{ 
	double a=sqrt((mc1.dbX-mc2.dbX)*(mc1.dbX-mc2.dbX)
		+(mc1.dbY-mc2.dbY)*(mc1.dbY-mc2.dbY)); 

	if (a-5<(mc1.dbWidth+mc2.dbWidth)/2)
	{ 
		return true; 
	}
	else
	{ 
		return false; 
	} 
}


//��ײ����
void CGameClientView::mcFanTang(BALL &mc)
{ 
	// С���˶�������x������ļн� 
	double  ang = atan2(mc.dbDy,mc.dbDx);

	// ��ײ����x����н� 
	double ang1 = atan2(mc.dbY,mc.dbX);

	// ����� 
	double _ang1 = 2*ang1-ang- PI; 

	//�˶�ʸ�� 
	double r1=sqrt(mc.dbDx*mc.dbDx+mc.dbDy*mc.dbDy);

	// ��ײ������� 
	mc.dbDx = r1*cos((double)_ang1); 
	mc.dbDy = r1*sin((double)_ang1);
}

void CGameClientView::StartSicboAnim(BYTE bySicbo[],int iStartIndex)
{
	memcpy(m_bySicbo, bySicbo, 2);
	m_iSicboAnimIndex = iStartIndex;

	// �����Ӷ���
	//CImageHandle ImageHandleSaizi(&m_ImageSaizi);
	int nImageHeight=m_ImageSaizi.GetHeight();
	int nImageWidth=m_ImageSaizi.GetWidth()/21;
	BALL sBall;
	ZeroMemory(&sBall,sizeof(sBall));
	m_arBall.RemoveAll();
	sBall.dbX = -35.1f;
	sBall.dbY = 30.4f;
	sBall.dbWidth = nImageWidth-1;
	sBall.dbHeight = nImageHeight -1;
	sBall.dbDx = 7.8f * ((0==rand()%2)?1:-1);
	sBall.dbDy = 6.2f * ((0==rand()%2)?1:-1);
	sBall.iIndex = rand()%25;
	m_arBall.Add(sBall);

	sBall.dbX = 20.3f;
	sBall.dbY = -23.4f;
	sBall.dbDx = 6.3f * ((0==rand()%2)?1:-1);
	sBall.dbDy = 5.3f * ((0==rand()%2)?1:-1);
	sBall.iIndex = rand()%30;
	m_arBall.Add(sBall);
	SetTimer(IDI_SIBO_PLAY, 100, NULL);	
	RefreshGameView();
	if (iStartIndex<20)
	{
		m_pGameClientDlg->PlayGameSound(AfxGetInstanceHandle(),TEXT("SICBO_WAV"));
	}
}
//������ͼ
void CGameClientView::RefreshGameView()
{
	CRect rect;
	GetClientRect(&rect);
	InvalidGameView(rect.left,rect.top,rect.Width(),rect.Height());

	return;
}
void CGameClientView::StopSicboAnim(void)
{
	KillTimer(IDI_SIBO_PLAY);
	m_iSicboAnimIndex = -1;
	RefreshGameView();
}

//�滭����
void CGameClientView::DrawNumberString(CDC * pDC, __int64 lNumber, INT nXPos, INT nYPos, bool bMeScore)
{
	//������Դ
	//CImageHandle HandleScoreNumber(&m_ImageNumber);

	CSize SizeScoreNumber(m_ImageNumber.GetWidth()/10,m_ImageNumber.GetHeight());

	//������Ŀ
	LONG lNumberCount=0;
	__int64 lNumberTemp=lNumber;
	do
	{
		lNumberCount++;
		lNumberTemp/=10;
	} while (lNumberTemp>0);

	//λ�ö���
	INT nYDrawPos=nYPos-SizeScoreNumber.cy/2;
	INT nXDrawPos=nXPos+lNumberCount*SizeScoreNumber.cx/2-SizeScoreNumber.cx;

	//�滭����
	for (LONG i=0;i<lNumberCount;i++)
	{
		//�滭����
		int lCellNumber=(int)(lNumber%10);
		if ( bMeScore )
		{
			m_ImageNumber.TransDrawImage(pDC,nXDrawPos,nYDrawPos,SizeScoreNumber.cx,SizeScoreNumber.cy,
				lCellNumber*SizeScoreNumber.cx,0,RGB(255,0,255));
		}
		else
		{
			m_ImageNumber.TransDrawImage(pDC,nXDrawPos,nYDrawPos,SizeScoreNumber.cx,SizeScoreNumber.cy,
				lCellNumber*SizeScoreNumber.cx,0,RGB(255,0,255));
		}

		//���ñ���
		lNumber/=10;
		nXDrawPos-=SizeScoreNumber.cx;
	};

	return;
}
BOOL CGameClientView::PreTranslateMessage(MSG* pMsg)
{

	return CGameFrameView::PreTranslateMessage(pMsg);
}

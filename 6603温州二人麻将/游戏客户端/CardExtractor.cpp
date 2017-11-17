// CardExtractor.cpp : ʵ���ļ�
//

#include "stdafx.h"
#include "resource.h"
#include "CardExtractor.h"
#include "GameClientDlg.h"

                    
// CCardExtractor �Ի���

IMPLEMENT_DYNAMIC(CCardExtractor, CDialog)

CCardExtractor::CCardExtractor(CWnd* pParent /*=NULL*/)
	: CDialog(IDD_CARD_EXTRACTOR, pParent)
{
	m_pClientDlg = NULL;
	m_CardCtrl[0].SetCardData(NULL,0,0);
	m_CardCtrl[0].SetPositively(true);
	m_CardCtrl[0].SetDisplayItem(true);

	m_CardCtrl[1].SetCardData(NULL,0,0);
	m_CardCtrl[1].SetPositively(true);
	m_CardCtrl[1].SetDisplayItem(true);

	m_CardCtrl[2].SetCardData(NULL,0,0);
	m_CardCtrl[2].SetPositively(true);
	m_CardCtrl[2].SetDisplayItem(true);

	m_CardCtrl[3].SetCardData(NULL,0,0);
	m_CardCtrl[3].SetPositively(true);
	m_CardCtrl[3].SetDisplayItem(true);

	m_cbHoverCard=0;

}

CCardExtractor::~CCardExtractor()
{
}

void CCardExtractor::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
}


BEGIN_MESSAGE_MAP(CCardExtractor, CDialog)
	ON_WM_PAINT()
	ON_WM_LBUTTONDOWN()
	ON_WM_SETCURSOR()
END_MESSAGE_MAP()


// CCardExtractor ��Ϣ�������

void CCardExtractor::OnPaint()
{
	CPaintDC dc(this); // device context for painting
	// TODO: �ڴ˴������Ϣ����������
	// ��Ϊ��ͼ��Ϣ���� CDialog::OnPaint()

	m_CardCtrl[0].DrawCardControl(&dc);
	m_CardCtrl[1].DrawCardControl(&dc);
	m_CardCtrl[2].DrawCardControl(&dc);
	m_CardCtrl[3].DrawCardControl(&dc);

	if(m_cbHoverCard!=0)
		g_CardResource.m_ImageUserBottom.DrawCardItem(&dc,m_cbHoverCard,30,50);

}

BOOL CCardExtractor::OnInitDialog()
{
	CDialog::OnInitDialog();

	// TODO:  �ڴ���Ӷ���ĳ�ʼ��
	CRect rect;
	GetClientRect(rect);
	INT nWidth = rect.Width();
	INT nHeight = 100;// rect.Height();

	m_CardCtrl[0].SetBenchmarkPos(nWidth/2-80,nHeight + 5,enXCenter,enYBottom);
	m_CardCtrl[1].SetBenchmarkPos(nWidth/2-80,nHeight + 105,enXCenter,enYBottom);
	m_CardCtrl[2].SetBenchmarkPos(nWidth/2-80,nHeight + 205,enXCenter,enYBottom);
	m_CardCtrl[3].SetBenchmarkPos(nWidth/2-80,nHeight + 305,enXCenter,enYBottom);

	BYTE byCardData[4][9]={{0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09},						//����
	{0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19},						//����
	{0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29},						//ͬ��
	{0x31,0x32,0x33,0x34,0x35,0x36,0x37}									//����
	};
	m_CardCtrl[0].SetCardData(byCardData[0], 9, 0);
	m_CardCtrl[1].SetCardData(byCardData[1], 9, 0);
	m_CardCtrl[2].SetCardData(byCardData[2], 9, 0);
	m_CardCtrl[3].SetCardData(byCardData[3], 7, 0);

	return TRUE;  // return TRUE unless you set the focus to a control
	// �쳣: OCX ����ҳӦ���� FALSE
}

void CCardExtractor::OnLButtonDown(UINT nFlags, CPoint point)
{
	// TODO: �ڴ������Ϣ�����������/�����Ĭ��ֵ

	CDialog::OnLButtonDown(nFlags, point);

	for (INT i=0; i<4; ++i)
	{
		//��ȡ�˿�
		BYTE cbHoverCard=m_CardCtrl[i].GetHoverCard();
		if (cbHoverCard!=0)
		{
			m_cbHoverCard=cbHoverCard;
			Invalidate(FALSE);
			//// ��Ҫ���Ƶ��Ʒ��͵������
			//if (NULL != m_pClientDlg)
			//{
			//	((CGameClientEngine *)m_pClientDlg)->SendSocketData(SUB_C_SET_CARD, &cbHoverCard, sizeof(cbHoverCard));
			//}
			break;
		}
	}	
}
void CCardExtractor::OnOK()
{
	if(m_cbHoverCard!=0 && NULL != m_pClientDlg)
	{//AfxMessageBox(_T("huan"));
		((CGameClientEngine *)m_pClientDlg)->SendSocketData(SUB_C_SET_CARD, &m_cbHoverCard, sizeof(m_cbHoverCard));
	}
	//��ȡ����
	__super::OnOK();
}

BOOL CCardExtractor::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message)
{
	//��ȡ���
	CPoint MousePoint;
	GetCursorPos(&MousePoint);
	ScreenToClient(&MousePoint);

	//�������
	bool bRePaint=false;
	bool bHandle= false;
	for (INT i=0; i<4; ++i)
	{
		bHandle = m_CardCtrl[i].OnEventSetCursor(MousePoint,bRePaint);
		if (bHandle)
		{
			break;
		}
	}

	//������
	if (bHandle==false)
		__super::OnSetCursor(pWnd,nHitTest,message);
	return true;
}

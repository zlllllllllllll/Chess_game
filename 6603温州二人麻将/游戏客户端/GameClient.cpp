#include "Stdafx.h"
#include "GameClient.h"
#include "GameClientDlg.h"

//Ӧ�ó������
CGameClientApp theApp;
//#ifdef VIDEO_GAME
////��Ƶ����
//CVideoServiceManager g_VedioServiceManager;
//#endif

//////////////////////////////////////////////////////////////////////////

//���캯��
CGameClientApp::CGameClientApp()
{
}

//��������
CGameClientApp::~CGameClientApp() 
{
}

//��������
CGameFrameEngine * CGameClientApp::GetGameFrameEngine(DWORD dwSDKVersion)
{
	//�汾���
	if (InterfaceVersionCompare(VERSION_FRAME_SDK,dwSDKVersion)==false)
	{
		ASSERT(FALSE);
		return NULL;
	}

	//��������
	return new CGameClientEngine;
};
//////////////////////////////////////////////////////////////////////////

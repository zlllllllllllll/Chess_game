#include "Stdafx.h"
#include "GameClient.h"
#include "GameOption.h"
#include "GameClientDlg.h"
#include "CardExtractor.h"

//////////////////////////////////////////////////////////////////////////

//游戏定时器
#define IDI_START_GAME				200									//开始定时器
#define IDI_OPERATE_CARD			201									//操作定时器
#define IDI_DINGDI_CARD			    202									//操作定时器

//游戏定时器
#define TIME_START_GAME				60									//开始定时器
#define TIME_HEAR_STATUS			15									//出牌定时器
#define TIME_OPERATE_CARD			15									//操作定时器

//////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CGameClientEngine, CGameFrameEngine)
	ON_MESSAGE(IDM_START,OnStart)
	ON_MESSAGE(IDM_OUT_CARD,OnOutCard)
	ON_MESSAGE(IDM_OUT_INVALID_CARD,OnOutInvalidCard)
	ON_MESSAGE(IDM_LISTEN_CARD,OnListenCard)
	ON_MESSAGE(IDM_CARD_OPERATE,OnCardOperate)
	ON_MESSAGE(IDM_TRUSTEE_CONTROL,OnStusteeControl)
	ON_MESSAGE(IDM_DING_DI,OnDingDi)
	ON_MESSAGE(IDM_DISPATCH_CARD, OnDispatchCard)
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////////

//构造函数
CGameClientEngine::CGameClientEngine()
{
	//游戏变量
	m_wBankerUser=INVALID_CHAIR;
	m_wCurrentUser=INVALID_CHAIR;

	//状态变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;

	//堆立变量
	m_wHeapHand=0;
	m_wHeapTail=0;
	ZeroMemory(m_cbHeapCardInfo,sizeof(m_cbHeapCardInfo));

	//托管变量
	m_bStustee=false;
	m_wTimeOutCount =0;

	//出牌信息
	m_cbOutCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
	ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

	//组合扑克
	ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
	ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));

	//扑克变量
	m_cbLeftCardCount=0;
	ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));
	m_bySicboAnimCount = 0;
	ZeroMemory(&m_sGamePlay,sizeof(m_sGamePlay));

	m_bChineseVoice=false;
	m_cbUserAction=0;
	return;
}

//析构函数
CGameClientEngine::~CGameClientEngine()
{
}

//初始函数
bool CGameClientEngine::OnInitGameEngine()
{

	//设置图标
	HICON hIcon=LoadIcon(AfxGetInstanceHandle(),MAKEINTRESOURCE(IDR_MAINFRAME));
	m_pIClientKernel->SetGameAttribute(KIND_ID,GAME_PLAYER,VERSION_CLIENT,hIcon,GAME_NAME);
	SetIcon(hIcon,TRUE);
	SetIcon(hIcon,FALSE);

	//加载资源
	g_CardResource.LoadResource();

	//BYTE cbCardData[]={1,2,3,4,5,6,7,8,9,1,2,3,4,5};

	////扑克设置
	//m_GameClientView.m_UserCard[0].SetCardData(13,false);
	//m_GameClientView.m_UserCard[1].SetCardData(13,false);
	//m_GameClientView.m_UserCard[2].SetCardData(13,false);
	//m_GameClientView.m_HandCardControl.SetCardData(cbCardData,13,cbCardData[13]);


	//BYTE cbCardData1[]={1,2,3,4,5,6,7,8,9,1,2,3,4,5,7,8,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

	//BYTE cbCardData2[]={1,1,1,1};
	////扑克设置
	//for (WORD i=0;i<GAME_PLAYER;i++)
	//{
	//	m_GameClientView.m_TableCard[i].SetCardData(NULL,0);
	//	m_GameClientView.m_DiscardCard[i].SetCardData(cbCardData1,20);
	//	m_GameClientView.m_WeaveCard[i][0].SetCardData(cbCardData2,4);
	//	m_GameClientView.m_WeaveCard[i][1].SetCardData(cbCardData2,4);
	//	m_GameClientView.m_WeaveCard[i][2].SetCardData(cbCardData2,4);
	//	m_GameClientView.m_WeaveCard[i][3].SetCardData(cbCardData2,4);
	//}

	//m_wBankerUser=0;
	////堆立扑克
	//for (WORD i=0;i<GAME_PLAYER;i++)
	//{
	//	m_GameClientView.m_HeapCard[i].SetCardData(0,0,HEAP_FULL_COUNT);
	//}
	//打开注册表
	CRegKey RegParamter;
	TCHAR szRegName[MAX_PATH];
	_sntprintf(szRegName,sizeof(szRegName),TEXT("Software\\KKKKKK\\%s"),"温州二人麻将");
	if (RegParamter.Open(HKEY_CURRENT_USER,szRegName,KEY_READ)==ERROR_SUCCESS)
	{
		TCHAR szReadData[1024]=TEXT("");
		DWORD dwDataType,dwReadData,dwDataSize;
		dwDataSize=sizeof(dwReadData);
		LONG lErrorCode=RegParamter.QueryValue(TEXT("IsChineseVoice"),&dwDataType,&dwReadData,&dwDataSize);
		if (lErrorCode==ERROR_SUCCESS)
		{
			WORD w=(WORD)dwReadData;
			if(w!=0)
				m_bChineseVoice=true;
		}
	}


	CGlobalUnits *pGlobalUnits=CGlobalUnits::GetInstance();
	IGameFrameWnd * pIGameFrameWnd=(IGameFrameWnd *)pGlobalUnits->QueryGlobalModule(MODULE_GAME_FRAME_WND,IID_IGameFrameWnd,VER_IGameFrameWnd);
	if(pIGameFrameWnd)pIGameFrameWnd->RestoreWindow();

	return true;
}

//重置框架
bool CGameClientEngine::OnResetGameEngine()
{
	//游戏变量
	m_wBankerUser=INVALID_CHAIR;
	m_wCurrentUser=INVALID_CHAIR;

	//状态变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;

	//托管变量
	m_bStustee=false;
	m_wTimeOutCount =0;

	//堆立变量
	m_wHeapHand=0;
	m_wHeapTail=0;
	ZeroMemory(m_cbHeapCardInfo,sizeof(m_cbHeapCardInfo));

	//出牌信息
	m_cbOutCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
	ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

	//组合扑克
	ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
	ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));

	//扑克变量
	m_cbLeftCardCount=0;
	ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));
	m_bySicboAnimCount =0 ;
	ZeroMemory(&m_sGamePlay,sizeof(m_sGamePlay));

	KillGameClock(IDI_START_GAME);
	m_GameClientView.m_btStart.ShowWindow(SW_HIDE);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);
	m_GameClientView.m_ScoreControl.RestorationData();

	//设置界面
	m_GameClientView.SetDiscUser(INVALID_CHAIR);
	m_GameClientView.SetHuangZhuang(false);
	m_GameClientView.SetStatusFlag(false,false);
	m_GameClientView.SetBankerUser(INVALID_CHAIR);
	m_GameClientView.SetUserAction(INVALID_CHAIR,0);
	m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	m_GameClientView.SetUserListenStatus(INVALID_CHAIR,false);

	//扑克设置
	m_GameClientView.m_UserCard[0].SetCardData(0,false);
	m_GameClientView.m_UserCard[1].SetCardData(0,false);
	m_GameClientView.m_HandCardControl.SetCardData(NULL,0,0);
	m_GameClientView.SetGodsCard(0x00);
	m_GameClientView.m_HandCardControl.SetGodsCard(0x00);
	m_GameClientView.SetDingMaiValue(NULL);


	//扑克设置
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_GameClientView.m_TableCard[i].SetCardData(NULL,0);
		m_GameClientView.m_DiscardCard[i].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][0].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][1].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][2].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][3].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][4].SetCardData(NULL,0);
	}

	//堆立扑克
	for (WORD i=0;i<4;i++)
	{
		m_cbHeapCardInfo[i][0]=0;
		m_cbHeapCardInfo[i][1]=0;
		m_GameClientView.m_HeapCard[i].SetGodsCard(0x00,0x00,0x00);
		m_GameClientView.m_HeapCard[i].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
	}

	//状态变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;

	//游戏变量
	m_wCurrentUser=INVALID_CHAIR;

	//出牌信息
	m_cbOutCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
	ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

	//组合扑克
	ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
	ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));

	//堆立扑克
	m_wHeapHand=0;
	m_wHeapTail=0;
	ZeroMemory(m_cbHeapCardInfo,sizeof(m_cbHeapCardInfo));

	//扑克变量
	m_cbLeftCardCount=0;
	ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));

	m_cbUserAction = 0;
	return true;
}

//游戏设置
void CGameClientEngine::OnGameOptionSet()
{
	////构造数据
	//CGameOption GameOption;
	//GameOption.m_bEnableSound=IsEnableSound();
	//GameOption.m_bAllowLookon=IsAllowUserLookon();
	//GameOption.m_bChineseVoice=m_bChineseVoice;
	////配置数据
	//if (GameOption.DoModal()==IDOK)
	//{
	//	EnableSound(GameOption.m_bEnableSound);
	//	AllowUserLookon(0,GameOption.m_bAllowLookon);
	//	m_bChineseVoice=GameOption.m_bChineseVoice;
	//	//打开注册表
	//	CRegKey RegParamter;
	//	TCHAR szRegName[MAX_PATH];
	//	_sntprintf(szRegName,sizeof(szRegName),TEXT("Software\\KKKKKK\\%s"),"温州二人麻将");
	//	if (RegParamter.Create(HKEY_CURRENT_USER,szRegName)==ERROR_SUCCESS)
	//	{
	//		if(m_bChineseVoice)
	//			RegParamter.SetDWORDValue(TEXT("UserDataBasePort"),(WORD)1);
	//		else
	//			RegParamter.SetDWORDValue(TEXT("UserDataBasePort"),(WORD)0);
	//	}
	//}

	return;
}
//时钟删除
bool CGameClientEngine::OnEventGameClockKill(WORD wChairID)
{
	return true;
}
//时间消息
bool CGameClientEngine::OnEventGameClockInfo(WORD wChairID, UINT nElapse, WORD wClockID)
{
	switch (wClockID)
	{
	case IDI_START_GAME:		//开始游戏
		{
			if (nElapse==0)
			{
				AfxGetMainWnd()->PostMessage(WM_CLOSE);
				return false;
			}
			if ((nElapse<=5)&&(IsLookonMode()==false))
			{
					PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
			}

			return true;
		}
	case IDI_DINGDI_CARD:		//开始游戏
		{
			if (IsLookonMode())
			{
				return true;
			}
			WORD wMeChairID=GetMeChairID();
			if ((m_wCurrentUser == wMeChairID) && (0 == nElapse))
			{
				OnDingDi(1, 0);
				return true ;
			}

			if ((nElapse<=3)&&(wChairID==wMeChairID))
			{
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
			}
			return true;
		}
	case IDI_OPERATE_CARD:		//操作定时器
		{
			//if ((m_wTimeOutCount>=3)&&(m_bStustee==false||m_bHearStatus==true))	OnStusteeControl(0,0);

			//自动出牌
			bool bAutoOutCard=m_bHearStatus;
			if ((bAutoOutCard==true)&&(m_GameClientView.m_ControlWnd.IsWindowVisible()))
				bAutoOutCard=false;
			if((bAutoOutCard==false)&&(m_bStustee==true))
			{
				bAutoOutCard=true;
			}


			//超时判断
			if ((IsLookonMode()==false)&&((nElapse==0)||(bAutoOutCard==true)))
			{
				//获取位置
				WORD wMeChairID=GetMeChairID();

				//动作处理
				if (wChairID==wMeChairID)
				{
					//if((m_bStustee==false)&&(m_bHearStatus==false))
					//{
					//	m_wTimeOutCount++;
						//CString strTemp;
						//strTemp.Format(TEXT("您已经超时%d次"),m_wTimeOutCount);
						//m_pIStringMessage->InsertSystemString(LPCTSTR(strTemp));
						//	if(m_wTimeOutCount==3)
						//{
						//	m_pIStringMessage->InsertSystemString(TEXT("由于您多次超时，切换为“系统托管”模式."));
						//}
					 //}

							if(m_bStustee==false &&m_bHearStatus==false && ++m_wTimeOutCount>=3 )
				    	{
						m_wTimeOutCount = 0;
						OnStusteeControl(0,0);
						m_pIStringMessage->InsertSystemString(TEXT("由于您多次超时，切换为“系统托管”模式."));
				     	}




					if (m_wCurrentUser==wMeChairID)
					{



						if (m_cbUserAction&WIK_CHI_HU)
						{


							OnCardOperate( WIK_CHI_HU,0 );
							KillGameClock(IDI_OPERATE_CARD);
							return true;
						}


              //先出字牌。
							BYTE cbCardData=m_GameClientView.m_HandCardControl.GetMeOutCard();

		              	if  (cbCardData!=0x00)
						{
								OnOutCard(cbCardData,cbCardData);

								KillGameClock(IDI_OPERATE_CARD);
								return true;

						}else
						{
							KillGameClock(IDI_OPERATE_CARD);
								if(m_bStustee)
		OnStusteeControl(0,0);

							SetGameClock(GetMeChairID(),IDI_OPERATE_CARD,TIME_OPERATE_CARD);
										//取消托管

							return true;
						}



						BYTE cbGods=m_GameClientView.GetGodsCard();
							INT iGodsIndex = m_GameLogic.SwitchToCardIndex(cbGods);

						for(BYTE i=27; i<MAX_INDEX; i++)
		                   {
							   if (m_cbCardIndex[i]==0) continue;
		                      	if (i == iGodsIndex)  // 财神不能出
		                        	{
			                       	continue;
		                           	}



								if (m_cbCardIndex[i]==1)
								{


								cbCardData=m_GameLogic.SwitchToCardData(i);
								OnOutCard(cbCardData,cbCardData);

								KillGameClock(IDI_OPERATE_CARD);
								return true;
								}

	                    	}

						   for(BYTE i=27; i<MAX_INDEX; i++)
		                   {
							   if (m_cbCardIndex[i]==0) continue;
		                      	if (i == iGodsIndex)  // 财神不能出
		                        	{
			                       	continue;
		                           	}

		                     	if (VerdictOutCard(m_GameLogic.SwitchToCardData(i))==false)
									continue;
								cbCardData=m_GameLogic.SwitchToCardData(i);
								OnOutCard(cbCardData,cbCardData);
								KillGameClock(IDI_OPERATE_CARD);
								return true;

	                    	}



						   	cbCardData=m_GameClientView.m_HandCardControl.GetMeOutCard();
							//出牌效验
						if (VerdictOutCard(cbCardData)==true)
						{
	                       	OnOutCard(cbCardData,cbCardData);
							KillGameClock(IDI_OPERATE_CARD);
							return true;
						}


	                   	for (BYTE i=MAX_INDEX-1; i>=0; --i)
	                     	{
								if (m_cbCardIndex[i]==0) continue;
	                  		if (i == iGodsIndex)   // 财神不能出
	                    		{
	                 			continue;
	                       		}
		                    if (VerdictOutCard(m_GameLogic.SwitchToCardData(i))==false)
									continue;
								cbCardData=m_GameLogic.SwitchToCardData(i);
								OnOutCard(cbCardData,cbCardData);
								KillGameClock(IDI_OPERATE_CARD);
								return true;
	                     	}
						for (BYTE i=0;i<MAX_INDEX;i++)
							{
								//出牌效验
								if (m_cbCardIndex[i]==0) continue;
									if (i == iGodsIndex)  // 财神不能出
		                        	{
			                       	continue;
		                           	}
								if (VerdictOutCard(m_GameLogic.SwitchToCardData(i))==false)
									continue;

								//设置变量
								cbCardData=m_GameLogic.SwitchToCardData(i);
								OnOutCard(cbCardData,cbCardData);
								KillGameClock(IDI_OPERATE_CARD);
								return true;
							}


/*
						//获取扑克
						BYTE cbCardData=m_GameClientView.m_HandCardControl.GetMeOutCard();

						//出牌效验
						if (VerdictOutCard(cbCardData)==false)
						{
							for (BYTE i=0;i<MAX_INDEX;i++)
							{
								//出牌效验
								if (m_cbCardIndex[i]==0) continue;
								if (VerdictOutCard(m_GameLogic.SwitchToCardData(i))==false)
									continue;

								//设置变量
								cbCardData=m_GameLogic.SwitchToCardData(i);
							}
						}

						//出牌动作
						OnOutCard(cbCardData,cbCardData);*/
					}
					else
						OnCardOperate(WIK_NULL,0);
				}

				return true;
			}

			//播放声音
			if ((nElapse<=3)&&(wChairID==GetMeChairID())&&(IsLookonMode()==false))
			{
					PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WARN"));
			}

			return true;
		}
	}

	return true;
}

//旁观状态
bool CGameClientEngine::OnEventLookonMode(VOID * pData, WORD wDataSize)
{
	//扑克控制
	m_GameClientView.m_HandCardControl.SetDisplayItem(IsAllowLookon());
	m_GameClientView.RefreshGameView();
	return true;
}

//网络消息
bool CGameClientEngine::OnEventGameMessage(WORD wSubCmdID, VOID * pData, WORD wDataSize)
{
	switch (wSubCmdID)
	{
	case SUB_S_GAME_START:		//游戏开始
		{
			return OnSubGameStart(pData,wDataSize);
		}
	case SUB_S_OUT_CARD:		//用户出牌
		{
			return OnSubOutCard(pData,wDataSize);
		}
	case SUB_S_SEND_CARD:		//发牌消息
		{
			return OnSubSendCard(pData,wDataSize);
		}
	case SUB_S_LISTEN_CARD:		//听牌处理
		{
			return OnSubListenCard(pData,wDataSize);
		}
	case SUB_S_OPERATE_NOTIFY:	//操作提示
		{
			return OnSubOperateNotify(pData,wDataSize);
		}
	case SUB_S_OPERATE_RESULT:	//操作结果
		{
			return OnSubOperateResult(pData,wDataSize);
		}
	case SUB_S_GAME_END:		//游戏结束
		{
			return OnSubGameEnd(pData,wDataSize);
		}
	case SUB_S_TRUSTEE:			//用户托管
		{
			return OnSubTrustee(pData,wDataSize);
		}
	case SUB_S_DINGDI:
		{
			return OnSubDingDi(pData,wDataSize);  // 庄家买底
		}
	case SUB_S_GAME_PLAY:
		{
			return OnSubGamePlay(pData,wDataSize);
		}
	case SUB_C_CHECK_SUPER:
		{
			// 弹出提牌器
			CCardExtractor ret;
			ret.m_pClientDlg = this;
			ret.DoModal();
			return true;
		}
	default: break;
	}

	return true;
}
void CGameClientEngine::OnLookonViewChange(bool bLookon)
{
//	m_GameClientView.m_bCanLookOn=bLookon;
	m_GameClientView.RefreshGameView();
}
//游戏场景
bool CGameClientEngine::OnEventSceneMessage(BYTE cbGameStatus, bool bLookonUser, VOID * pData, WORD wDataSize)
{
	//m_pIClientKernel
	//IClientKernel *pIClientKernel = ( IClientKernel * )GetClientKernel( IID_IClientKernel, VER_IClientKernel );
	//pServerAttribute  = pIClientKernel->GetServerAttribute();
	switch (cbGameStatus)
	{
	case GS_MJ_FREE:	//空闲状态
		{
			//效验数据
			if (wDataSize!=sizeof(CMD_S_StatusFree)) return false;
			CMD_S_StatusFree * pStatusFree=(CMD_S_StatusFree *)pData;

			//设置数据
			m_wBankerUser=pStatusFree->wBankerUser;
			m_GameClientView.SetBaseScore(pStatusFree->lCellScore);
			m_GameClientView.m_HandCardControl.SetDisplayItem(true);
			//托管设置
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				m_GameClientView.SetTrustee(SwitchViewChairID(i),pStatusFree->bTrustee[i]);
			}

			//设置界面
			for (WORD i=0;i<4;i++)
			{
				m_cbHeapCardInfo[i][0]=0;
				m_cbHeapCardInfo[i][1]=0;
				m_GameClientView.m_HeapCard[i].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
			}

			//设置控件
			if (IsLookonMode()==false)
			{
				m_GameClientView.m_btStart.ShowWindow(SW_SHOW);
				m_GameClientView.m_btStart.SetFocus();
				m_GameClientView.m_btStusteeControl.EnableWindow(TRUE);
				SetGameClock(GetMeChairID(),IDI_START_GAME,TIME_START_GAME);
			}
			m_GameClientView.m_btMaiDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btMaiCancel.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingCancel.ShowWindow(SW_HIDE);

			//丢弃效果
			m_GameClientView.SetDiscUser(INVALID_CHAIR);
			m_GameClientView.SetTimer(IDI_DISC_EFFECT,250,NULL);

			//更新界面
			m_GameClientView.RefreshGameView();

			return true;
		}
	case GS_MJ_MAIDI:
		{
			//效验数据
			if (wDataSize!=sizeof(CMD_S_StatusMaiDi)) return false;
			CMD_S_StatusMaiDi * pStatusMaiDi=(CMD_S_StatusMaiDi *)pData;

			//设置数据
			m_wBankerUser=pStatusMaiDi->wBankerUser;
			m_GameClientView.SetBaseScore(pStatusMaiDi->lCellScore);
			m_GameClientView.m_HandCardControl.SetDisplayItem(true);
			m_wCurrentUser = INVALID_CHAIR;
			//托管设置
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				m_GameClientView.SetTrustee(SwitchViewChairID(i),pStatusMaiDi->bTrustee[i]);
			}

			//设置界面
			for (WORD i=0;i<4;i++)
			{
				m_cbHeapCardInfo[i][0]=0;
				m_cbHeapCardInfo[i][1]=0;
				m_GameClientView.m_HeapCard[i].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
			}

			m_GameClientView.m_btMaiDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btMaiCancel.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingCancel.ShowWindow(SW_HIDE);
			m_GameClientView.m_btStart.ShowWindow(SW_HIDE);

			//旁观界面
			if (IsLookonMode())
			{
				m_GameClientView.SetHuangZhuang(false);
				m_GameClientView.SetStatusFlag(false,false);
				m_GameClientView.SetUserAction(INVALID_CHAIR,0);
				m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
			}
			else
			{
				TCHAR szMsg[MAX_PATH];
				if (pStatusMaiDi->bBankerMaiDi)
				{
					// 庄家显示买庄，取消
					if (m_wBankerUser == GetMeChairID())
					{
						_sntprintf(szMsg, sizeof(szMsg),TEXT(""));// TEXT("本盘底数为：%I64d"), pStatusMaiDi->lBaseScore*2);
						m_GameClientView.SetCenterText(szMsg);
						m_GameClientView.m_btMaiDi.ShowWindow(SW_SHOW);
						m_GameClientView.m_btMaiCancel.ShowWindow(SW_SHOW);
						m_GameClientView.m_btMaiDi.EnableWindow(TRUE);
						m_GameClientView.m_btMaiCancel.EnableWindow(TRUE);
						m_wCurrentUser = m_wBankerUser;
					}
					else  // 显示等待庄家买底
					{
						TCHAR szNickName[32]={TEXT("庄家")};
						if (INVALID_CHAIR != m_wBankerUser)
						{
							if (NULL != GetTableUserItem(m_wBankerUser))
							{
								_sntprintf(szNickName, sizeof(szNickName), TEXT("%s"),GetTableUserItem(m_wBankerUser)->GetNickName());
							}
						}

						_sntprintf(szMsg, sizeof(szMsg), TEXT("等待 %s 买底 ..."),
							pStatusMaiDi->lBaseScore*2, szNickName);
						m_GameClientView.SetCenterText(szMsg);
					}

					m_GameClientView.SetCurrentUser(SwitchViewChairID(m_wBankerUser));
					SetGameClock(m_wBankerUser, IDI_DINGDI_CARD, TIME_OPERATE_CARD);
				}
				else // 庄家已经叫了
				{
					WORD wMeChair = GetMeChairID();
					// 设置显示
					if (m_wBankerUser == wMeChair)
					{
						m_GameClientView.SetCenterText(TEXT("等待闲家顶底……"));
					}
					else
					{
						TCHAR szMsg[MAX_PATH]={0};
						_sntprintf(szMsg, sizeof(szMsg),TEXT(""));// TEXT("目前底数为：%u"), pStatusMaiDi->lBaseScore*2);
						m_GameClientView.SetCenterText(szMsg);
						if (pStatusMaiDi->bMeDingDi && !IsLookonMode())
						{
							ActiveGameFrame();
							m_GameClientView.m_btDingDi.ShowWindow(SW_SHOW);
							m_GameClientView.m_btDingCancel.ShowWindow(SW_SHOW);
							m_GameClientView.m_btDingDi.EnableWindow(TRUE);
							m_GameClientView.m_btDingCancel.EnableWindow(TRUE);
							m_wCurrentUser = wMeChair;
						}
					}
					m_GameClientView.SetCurrentUser(SwitchViewChairID(wMeChair));
					SetGameClock(wMeChair, IDI_DINGDI_CARD, TIME_OPERATE_CARD);
				}
			}

			//更新界面
			m_GameClientView.RefreshGameView();
			return true;

		}
	case GS_MJ_PLAY:	//游戏状态
		{
			//效验数据
			if (wDataSize!=sizeof(CMD_S_StatusPlay)) return false;
			CMD_S_StatusPlay * pStatusPlay=(CMD_S_StatusPlay *)pData;

			//设置变量
			m_wBankerUser=pStatusPlay->wBankerUser;
			m_wCurrentUser=pStatusPlay->wCurrentUser;
			m_cbLeftCardCount=pStatusPlay->cbLeftCardCount;
			m_bStustee=pStatusPlay->bTrustee[GetMeChairID()];
			m_GameClientView.m_btMaiDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingDi.ShowWindow(SW_HIDE);
			m_GameClientView.m_btMaiCancel.ShowWindow(SW_HIDE);
			m_GameClientView.m_btDingCancel.ShowWindow(SW_HIDE);
			BYTE byUserDingDi[GAME_PLAYER];

			//托管设置
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				WORD wChairID = SwitchViewChairID(i);
				byUserDingDi[wChairID] = pStatusPlay->byDingDi[i];
				m_GameClientView.SetTrustee(wChairID,pStatusPlay->bTrustee[i]);
			}

			m_GameLogic.SetGodsCard(pStatusPlay->byGodsCardData);
			m_GameClientView.m_HandCardControl.SetGodsCard(pStatusPlay->byGodsCardData);
			m_GameClientView.SetDingMaiValue(byUserDingDi);
			m_GameClientView.SetGodsCard(pStatusPlay->byGodsCardData);

			//旁观
			if( IsLookonMode()==true )
				m_GameClientView.m_HandCardControl.SetDisplayItem(IsAllowLookon());

			m_wTimeOutCount=0;
			if(pStatusPlay->bTrustee[GetMeChairID()])
				m_GameClientView.m_btStusteeControl.SetButtonImage(IDB_BT_STOP_TRUSTEE,AfxGetInstanceHandle(),false,false);
			else
				m_GameClientView.m_btStusteeControl.SetButtonImage(IDB_BT_START_TRUSTEE,AfxGetInstanceHandle(),false,false);

			//听牌状态
			WORD wMeChairID=GetMeChairID();
			m_bHearStatus=(pStatusPlay->cbHearStatus[wMeChairID]==TRUE)?true:false;

			//历史变量
			m_wOutCardUser=pStatusPlay->wOutCardUser;
			m_cbOutCardData=pStatusPlay->cbOutCardData;
			CopyMemory(m_cbDiscardCard,pStatusPlay->cbDiscardCard,sizeof(m_cbDiscardCard));
			CopyMemory(m_cbDiscardCount,pStatusPlay->cbDiscardCount,sizeof(m_cbDiscardCount));

			//丢弃效果
			if(m_wOutCardUser != INVALID_CHAIR)
				m_GameClientView.SetDiscUser(SwitchViewChairID(m_wOutCardUser));
			m_GameClientView.SetTimer(IDI_DISC_EFFECT,250,NULL);

			//扑克变量
			CopyMemory(m_cbWeaveCount,pStatusPlay->cbWeaveCount,sizeof(m_cbWeaveCount));
			CopyMemory(m_WeaveItemArray,pStatusPlay->WeaveItemArray,sizeof(m_WeaveItemArray));
			m_GameLogic.SwitchToCardIndex(pStatusPlay->cbCardData,pStatusPlay->cbCardCount,m_cbCardIndex);
			m_GameClientView.m_HandCardControl.SetOutCardData(pStatusPlay->byOutCardIndex, MAX_INDEX);

			//辅助变量
			WORD wViewChairID[GAME_PLAYER]={0,0};
			for (WORD i=0;i<GAME_PLAYER;i++) wViewChairID[i]=SwitchViewChairID(i);

			//界面设置
			m_GameClientView.SetBaseScore(pStatusPlay->lCellScore);
			m_GameClientView.SetBankerUser(wViewChairID[m_wBankerUser]);

			//组合扑克
			BYTE cbWeaveCard[4]={0,0,0,0};
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				WORD wOperateViewID = SwitchViewChairID(i);
				for (BYTE j=0;j<m_cbWeaveCount[i];j++)
				{
					BYTE cbWeaveKind=m_WeaveItemArray[i][j].cbWeaveKind;
					BYTE cbCenterCard=m_WeaveItemArray[i][j].cbCenterCard;
					BYTE cbWeaveCardCount=m_GameLogic.GetWeaveCard(cbWeaveKind,cbCenterCard,cbWeaveCard);
					m_GameClientView.m_WeaveCard[wViewChairID[i]][j].SetCardData(cbWeaveCard,cbWeaveCardCount,m_WeaveItemArray[i][j].cbCenterCard);
					if ((cbWeaveKind&WIK_GANG)&&(m_WeaveItemArray[i][j].wProvideUser==i))
						m_GameClientView.m_WeaveCard[wViewChairID[i]][j].SetDisplayItem(false);
					WORD wProviderViewID = SwitchViewChairID(m_WeaveItemArray[i][j].wProvideUser);
					m_GameClientView.m_WeaveCard[wOperateViewID][j].SetDirectionCardPos(3-(wOperateViewID-wProviderViewID+4)%4);

				}

				//听牌状态
				if (pStatusPlay->cbHearStatus[i]==TRUE)
				{
					WORD wViewChairID=SwitchViewChairID(i);
					m_GameClientView.SetUserListenStatus(wViewChairID,true);
				}
			}

			//用户扑克
			if (m_wCurrentUser==GetMeChairID())
			{
				//调整扑克
				if (pStatusPlay->cbSendCardData!=0x00)
				{
					//变量定义
					BYTE cbCardCount=pStatusPlay->cbCardCount;
					BYTE cbRemoveCard[]={pStatusPlay->cbSendCardData};

					//调整扑克
					m_GameLogic.RemoveCard(pStatusPlay->cbCardData,cbCardCount,cbRemoveCard,1);
					pStatusPlay->cbCardData[pStatusPlay->cbCardCount-1]=pStatusPlay->cbSendCardData;
				}
				//设置扑克
				BYTE cbCardCount=pStatusPlay->cbCardCount;
				m_GameClientView.m_HandCardControl.SetCardData(pStatusPlay->cbCardData,cbCardCount-1,pStatusPlay->cbCardData[cbCardCount-1]);

			}
			else
				m_GameClientView.m_HandCardControl.SetCardData(pStatusPlay->cbCardData,pStatusPlay->cbCardCount,0);

			//扑克设置
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				//用户扑克
				if (i!=GetMeChairID())
				{
					BYTE cbCardCount=13-m_cbWeaveCount[i]*3;
					WORD wUserCardIndex=(wViewChairID[i]<2)?wViewChairID[i]:2;
					m_GameClientView.m_UserCard[wUserCardIndex].SetCardData(cbCardCount,(m_wCurrentUser==i));
				}

				//丢弃扑克
				WORD wViewChairID=SwitchViewChairID(i);
				m_GameClientView.m_DiscardCard[wViewChairID].SetCardData(m_cbDiscardCard[i],m_cbDiscardCount[i]);
			}

			//控制设置
			if (IsLookonMode()==false)
			{
				m_GameClientView.m_HandCardControl.SetPositively(true);
				m_GameClientView.m_HandCardControl.SetDisplayItem(true);
				m_GameClientView.m_btStusteeControl.EnableWindow(TRUE);
				if (m_wOutCardUser == GetMeChairID())
				{
					if (WIK_NULL == pStatusPlay->cbActionMask)
					{
						m_GameClientView.m_HandCardControl.UpdateCardDisable(true);
					}
				}
			}

			//堆立扑克
			for (WORD i=0;i<GAME_PLAYER;i++)
			{
				m_cbHeapCardInfo[i][0]=0;
				m_cbHeapCardInfo[i][1]=0;
			}

			//分发扑克
			// 第一把骰子的玩家 门前开始数牌
			BYTE cbSiceFirst=(HIBYTE(pStatusPlay->wSiceCount1) + LOBYTE(pStatusPlay->wSiceCount1)-1)%4;
			WORD wTakeChairID = (m_wBankerUser + 4 - cbSiceFirst)%4;
			BYTE cbSiceSecond= HIBYTE(pStatusPlay->wSiceCount2) + LOBYTE(pStatusPlay->wSiceCount2)
				+ (HIBYTE(pStatusPlay->wSiceCount1) + LOBYTE(pStatusPlay->wSiceCount1));
			if ((cbSiceSecond*2)>HEAP_FULL_COUNT)
			{
				wTakeChairID = (wTakeChairID + 1)%4;
				cbSiceSecond = cbSiceSecond-(HEAP_FULL_COUNT/2);
			}
			m_wHeapTail = wTakeChairID%4;
			//BYTE cbTakeCount=MAX_REPERTORY-m_cbLeftCardCount;
			//for (WORD i=0;i<4;i++)
			//{
			//	//计算数目
			//	BYTE cbValidCount=HEAP_FULL_COUNT-m_cbHeapCardInfo[wTakeChairID][1]-((i==0)?(cbSiceSecond-1)*2:0);
			//	BYTE cbRemoveCount=__min(cbValidCount,cbTakeCount);

			//	//提取扑克
			//	cbTakeCount-=cbRemoveCount;
			//	m_cbHeapCardInfo[wTakeChairID][(i==0)?1:0]+=cbRemoveCount;

			//	//完成判断
			//	if (cbTakeCount==0)
			//	{
			//		m_wHeapHand=wTakeChairID;
			//		break;
			//	}

			//	//切换索引
			//	wTakeChairID=(wTakeChairID+1)%4;
			//}
			BYTE cbTakeCount=MAX_REPERTORY-m_cbLeftCardCount-(MAX_COUNT-1)*GAME_PLAYER;
			m_wHeapHand = (m_wHeapTail+1)%4;
			m_cbHeapCardInfo[m_wHeapHand][0] = cbTakeCount;
			if (cbTakeCount >= HEAP_FULL_COUNT)
			{
				m_cbHeapCardInfo[m_wHeapHand][0] = HEAP_FULL_COUNT;
				cbTakeCount = cbTakeCount - HEAP_FULL_COUNT;
				m_wHeapHand = (m_wHeapHand+1)%4;
				m_cbHeapCardInfo[m_wHeapHand][0] = (BYTE) m_wHeapHand;
			}

			//堆立界面
			for (WORD i=0;i<4;i++)
			{
				m_GameClientView.m_HeapCard[i].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
			}
			// 换算出财神牌的位置
			BYTE byCount = HEAP_FULL_COUNT - m_cbHeapCardInfo[m_wHeapTail][1];
			BYTE bySicbo = HIBYTE(pStatusPlay->wSiceCount3) + LOBYTE(pStatusPlay->wSiceCount3);
			BYTE byChairID = (BYTE) wMeChairID;
			if (byCount >= bySicbo)
			{
				byChairID = (BYTE) m_wHeapTail;
			}
			else
			{
				byChairID = (m_wHeapTail + 4 - 1)%4;
				bySicbo =  bySicbo - byCount;
			}
			m_GameClientView.m_HeapCard[SwitchHeapViewChairID(byChairID)].SetGodsCard(pStatusPlay->byGodsCardData,bySicbo, m_cbHeapCardInfo[byChairID][1]);
			//m_GameClientView.m_HeapCard[SwitchViewChairID(byChairID)].SetGodsCard(pStatusPlay->byGodsCardData,bySicbo, m_cbHeapCardInfo[byChairID][1]);

			//历史扑克
			if (m_wOutCardUser!=INVALID_CHAIR)
			{
				WORD wOutChairID=SwitchViewChairID(m_wOutCardUser);
				m_GameClientView.SetOutCardInfo(wOutChairID,m_cbOutCardData);
			}


			//操作界面
			if ((IsLookonMode()==false)&&(pStatusPlay->cbActionMask!=WIK_NULL))
			{
				//获取变量
				BYTE cbActionMask=pStatusPlay->cbActionMask;
				BYTE cbActionCard=pStatusPlay->cbActionCard;

				//变量定义
				tagGangCardResult GangCardResult;
				ZeroMemory(&GangCardResult,sizeof(GangCardResult));

				//杠牌判断
				if ((cbActionMask&WIK_GANG)!=0)
				{
					//桌面杆牌
					if ((m_wCurrentUser==INVALID_CHAIR)&&(cbActionCard!=0))
					{
						GangCardResult.cbCardCount=1;
						GangCardResult.cbCardData[0]=cbActionCard;
					}

					//自己杆牌
					if ((m_wCurrentUser==GetMeChairID())||(cbActionCard==0))
					{
						WORD wMeChairID=GetMeChairID();
						m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
					}
				}

				//设置界面
				if (m_wCurrentUser==INVALID_CHAIR)
					SetGameClock(GetMeChairID(),IDI_OPERATE_CARD,TIME_OPERATE_CARD);
				if (IsLookonMode()==false)
				{
					m_GameClientView.m_ControlWnd.SetControlInfo(cbActionCard,cbActionMask,GangCardResult);
					m_cbUserAction = cbActionMask;
				}
			}

			//设置时间
			if (m_wCurrentUser!=INVALID_CHAIR)
			{
				//计算时间
				WORD wTimeCount=TIME_OPERATE_CARD;
				if ((m_bHearStatus==true)&&(m_wCurrentUser==GetMeChairID()))
					wTimeCount=TIME_HEAR_STATUS;
				//ASSERT(FALSE);

				if (m_wCurrentUser == GetMeChairID())
				{
					if (WIK_NULL == pStatusPlay->cbActionMask)
					{
						m_GameClientView.m_HandCardControl.UpdateCardDisable(true);
					}
				}

				//设置时间
				SetGameClock(m_wCurrentUser,IDI_OPERATE_CARD,wTimeCount);
			}

			//丢弃效果
			m_GameClientView.SetDiscUser(SwitchViewChairID(m_wOutCardUser));
			m_GameClientView.SetTimer(IDI_DISC_EFFECT,250,NULL);

			//取消托管
	if(m_bStustee)
		OnStusteeControl(0,0);

			//更新界面
			m_GameClientView.RefreshGameView();

			return true;
		}
	}

	return true;
}

//游戏开始
bool CGameClientEngine::OnSubGameStart(const void * pBuffer, WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_GameStart));
	if (wDataSize!=sizeof(CMD_S_GameStart))
		return false;


	//变量定义
	CMD_S_GameStart * pGameStart=(CMD_S_GameStart *)pBuffer;
	//设置状态
	SetGameStatus(GS_MJ_MAIDI);
	m_GameClientView.m_ScoreControl.RestorationData();
	m_GameClientView.SetCurrentUser(INVALID_CHAIR);
	// 设置变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;
	m_wBankerUser=pGameStart->wBankerUser;
	m_wCurrentUser = INVALID_CHAIR;

	//设置界面
	bool bPlayerMode=(IsLookonMode()==false);
	m_GameClientView.SetUserListenStatus(INVALID_CHAIR,false);
	m_GameClientView.m_HandCardControl.SetPositively(false);
	m_GameClientView.SetBankerUser(SwitchViewChairID(m_wBankerUser));
	m_GameClientView.m_bBankerCount=pGameStart->bBankerCount;
	m_GameClientView.SetDiscUser(INVALID_CHAIR);
	m_GameClientView.SetGodsCard(0x00);
	m_GameClientView.m_HandCardControl.SetGodsCard(0x00);
	m_GameClientView.m_HandCardControl.SetOutCardData(NULL, 0);
	m_GameClientView.m_HandCardControl.UpdateCardDisable();

	//旁观界面
	if (bPlayerMode==false)
	{
		m_GameClientView.SetHuangZhuang(false);
		m_GameClientView.SetStatusFlag(false,false);
		m_GameClientView.SetUserAction(INVALID_CHAIR,0);
		m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	}
	else
	{
		TCHAR szMsg[MAX_PATH];
		if (pGameStart->bMaiDi)
		{
			// 庄家显示买庄，取消
			if (m_wBankerUser == GetMeChairID())
			{
				_sntprintf(szMsg, sizeof(szMsg), TEXT(""));// TEXT("本盘底数为：%I64d"), pGameStart->lBaseScore*2);
				m_GameClientView.SetCenterText(szMsg);
				m_GameClientView.m_btMaiDi.ShowWindow(SW_SHOW);
				m_GameClientView.m_btMaiCancel.ShowWindow(SW_SHOW);
				m_GameClientView.m_btMaiDi.EnableWindow(TRUE);
				m_GameClientView.m_btMaiCancel.EnableWindow(TRUE);
			}
			else  // 显示等待庄家买底
			{
				TCHAR szNickName[32]={TEXT("庄家")};
				if (INVALID_CHAIR != m_wBankerUser)
				{
					if (NULL != GetTableUserItem(m_wBankerUser))
					{
						_sntprintf(szNickName, sizeof(szNickName), TEXT("%s"),GetTableUserItem(m_wBankerUser)->GetNickName());
					}
				}

				_sntprintf(szMsg, sizeof(szMsg), TEXT("等待 %s 买底"),
					/*pGameStart->lBaseScore*2,*/ szNickName);
				m_GameClientView.SetCenterText(szMsg);
			}
		}
	}

	//更新界面
	m_GameClientView.RefreshGameView();

	//激活框架
	if (bPlayerMode==true)
		ActiveGameFrame();

	//环境处理
	PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_START"));

	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_GameClientView.m_HeapCard[i].SetGodsCard(0,0,0);
	}

	//设置时间
	if (m_wBankerUser!=INVALID_CHAIR)
	{
		m_GameClientView.SetCurrentUser(SwitchViewChairID(m_wBankerUser));
		m_wCurrentUser = m_wBankerUser;
		SetGameClock(m_wBankerUser,IDI_DINGDI_CARD,TIME_OPERATE_CARD);
	}
	//托管设置
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_GameClientView.SetTrustee(SwitchViewChairID(i),pGameStart->bTrustee[i]);
	}
	return true;
}

// 游戏正式开始
bool CGameClientEngine::OnSubGamePlay(const void * pBuffer,WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_GamePlay));
	if (wDataSize!=sizeof(CMD_S_GamePlay))
		return false;

	//变量定义
	CMD_S_GamePlay * pGamePlay=(CMD_S_GamePlay *)pBuffer;
	memcpy(&m_sGamePlay,pBuffer, sizeof(m_sGamePlay));
	KillGameClock(IDI_DINGDI_CARD);

	//设置状态
	m_GameClientView.m_ScoreControl.RestorationData();
	m_GameClientView.SetCurrentUser(INVALID_CHAIR);

	//设置变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;
	m_wCurrentUser=pGamePlay->wCurrentUser;

	//出牌信息
	m_cbOutCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
	ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

	//组合扑克
	ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
	ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));
	m_bySicboAnimCount = 0;

	//设置界面
	bool bPlayerMode=(IsLookonMode()==false);
	m_GameClientView.SetDiscUser(INVALID_CHAIR);

	//旁观界面
	if (bPlayerMode==false)
	{
		m_GameClientView.SetHuangZhuang(false);
		m_GameClientView.SetStatusFlag(false,false);
		m_GameClientView.SetUserAction(INVALID_CHAIR,0);
		m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	}
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_cbHeapCardInfo[i][0]=0;
		m_cbHeapCardInfo[i][1]=0;
	}
	BYTE byDingMaiRet[GAME_PLAYER];
	//堆立扑克
	TCHAR szMessage[128]=TEXT("\r\n");
	TCHAR szMsg[128]=TEXT("");
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		BYTE byViewChair = (BYTE) SwitchViewChairID(i);
		byDingMaiRet[byViewChair] = (BYTE) SwitchViewChairID(i);

		IClientUserItem * pUserData=GetTableUserItem(i);
		if (NULL == pUserData)
		{
			continue ;
		}
		byDingMaiRet[byViewChair] = pGamePlay->byUserDingDi[i]<2?0:pGamePlay->byUserDingDi[i];
		if (i == m_wBankerUser)
		{
			_sntprintf(szMsg, sizeof(szMsg), TEXT("[%s]买底\r\n"),pUserData->GetNickName(),byDingMaiRet[byViewChair]);
		}
		else
		{
			_sntprintf(szMsg, sizeof(szMsg), TEXT("[%s]顶底\r\n"),pUserData->GetNickName(), byDingMaiRet[byViewChair]);
		}
		/*_tcscat_s*/ _tcscat(szMessage, /*sizeof),*/ szMsg);
	}
	//m_pIStringMessage->InsertSystemString(szMessage);

	m_GameClientView.SetDingMaiValue(byDingMaiRet);

	//扑克设置
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		//变量定义
		WORD wViewChairID=SwitchViewChairID(i);

		//旁观界面
		if (bPlayerMode==false)
		{
			m_GameClientView.m_TableCard[wViewChairID].SetCardData(NULL,0);
			m_GameClientView.m_DiscardCard[wViewChairID].SetCardData(NULL,0);
			m_GameClientView.m_WeaveCard[wViewChairID][0].SetCardData(NULL,0);
			m_GameClientView.m_WeaveCard[wViewChairID][1].SetCardData(NULL,0);
			m_GameClientView.m_WeaveCard[wViewChairID][2].SetCardData(NULL,0);
			m_GameClientView.m_WeaveCard[wViewChairID][3].SetCardData(NULL,0);
			m_GameClientView.m_WeaveCard[wViewChairID][4].SetCardData(NULL,0);
		}
	}

	WORD wMeChairID=GetMeChairID();

	//出牌提示
	if ((bPlayerMode==true)&&(m_wCurrentUser!=INVALID_CHAIR))
	{
		if (m_wCurrentUser==wMeChairID)
		{
			ActiveGameFrame();
		}
	}
	m_GameClientView.m_HandCardControl.SetOutCardData(NULL, 0);

	//更新界面
	m_GameClientView.SetCenterText(TEXT(""));

	BYTE bySicbo[2] = {HIBYTE(pGamePlay->wSiceCount1), LOBYTE(pGamePlay->wSiceCount1)};
	m_GameClientView.StartSicboAnim(bySicbo,20);
	//this->SendMessage(IDM_DISPATCH_CARD,0,0);
	return true;
}


//用户出牌
bool CGameClientEngine::OnSubOutCard(const void * pBuffer, WORD wDataSize)
{
	//效验消息
	ASSERT(wDataSize==sizeof(CMD_S_OutCard));
	if (wDataSize!=sizeof(CMD_S_OutCard)) return false;

	//消息处理
	CMD_S_OutCard * pOutCard=(CMD_S_OutCard *)pBuffer;
	//变量定义
	WORD wMeChairID=GetMeChairID();
	WORD wOutViewChairID=SwitchViewChairID(pOutCard->wOutCardUser);
	if ((pOutCard->wOutCardUser != wMeChairID) && (GS_MJ_PLAY != GetGameStatus()))
	{
		do
		{
			OnDispatchCard(1,0);
		} while (GS_MJ_PLAY != GetGameStatus());
	}

	//设置变量
	m_wCurrentUser=INVALID_CHAIR;
	m_wOutCardUser=pOutCard->wOutCardUser;
	m_cbOutCardData=pOutCard->cbOutCardData;
	BYTE byCardIndex = m_GameLogic.SwitchToCardIndex(m_cbOutCardData);
	m_GameClientView.m_HandCardControl.SetOutCardData(byCardIndex);
	m_GameClientView.m_HandCardControl.UpdateCardDisable();

	//其他用户
	if ((IsLookonMode()==true)||(pOutCard->wOutCardUser!=wMeChairID))
	{
		//环境设置
		KillGameClock(IDI_OPERATE_CARD);
		PlayCardSound(pOutCard->wOutCardUser,pOutCard->cbOutCardData);

		//出牌界面
		m_GameClientView.SetUserAction(INVALID_CHAIR,0);
		m_GameClientView.SetOutCardInfo(wOutViewChairID,pOutCard->cbOutCardData);
		//设置扑克
		if (wMeChairID == pOutCard->wOutCardUser)
		{
			//删除扑克
			BYTE cbCardData[MAX_COUNT];
			m_GameLogic.RemoveCard(m_cbCardIndex,pOutCard->cbOutCardData);

			//设置扑克
			BYTE cbCardCount=m_GameLogic.SwitchToCardData(m_cbCardIndex,cbCardData);
			m_GameClientView.m_HandCardControl.SetCardData(cbCardData,cbCardCount,0);
		}
		else
		{
			WORD wUserIndex=wOutViewChairID;
			m_GameClientView.m_UserCard[wUserIndex].SetCurrentCard(false);
		}
	}
	else
	{
		m_GameClientView.RefreshGameView();
	}
	return true;
}

//发牌消息
bool CGameClientEngine::OnSubSendCard(const void * pBuffer, WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_SendCard));
	if (wDataSize!=sizeof(CMD_S_SendCard)) return false;

	//变量定义
	CMD_S_SendCard * pSendCard=(CMD_S_SendCard *)pBuffer;

	//设置变量
	WORD wMeChairID=GetMeChairID();
	m_wCurrentUser=pSendCard->wCurrentUser;

	//丢弃扑克
	if ((m_wOutCardUser!=INVALID_CHAIR)&&(m_cbOutCardData!=0))
	{
		//丢弃扑克
		WORD wOutViewChairID=SwitchViewChairID(m_wOutCardUser);
		m_GameClientView.m_DiscardCard[wOutViewChairID].AddCardItem(m_cbOutCardData);
		m_GameClientView.SetDiscUser(wOutViewChairID);

		//设置变量
		m_cbOutCardData=0;
		m_wOutCardUser=INVALID_CHAIR;
	}

	//发牌处理
	if (pSendCard->cbCardData!=0)
	{
		//取牌界面
		WORD wViewChairID=SwitchViewChairID(m_wCurrentUser);
		if (m_wCurrentUser!=wMeChairID)
		{
			WORD wUserIndex=wViewChairID;
			m_GameClientView.m_UserCard[wUserIndex].SetCurrentCard(true);
		}
		else
		{
			m_cbCardIndex[m_GameLogic.SwitchToCardIndex(pSendCard->cbCardData)]++;
			m_GameClientView.m_HandCardControl.SetCurrentCard(pSendCard->cbCardData);
		}

		//扣除扑克
		DeductionTableCard(true);
	}

	//当前用户
	if ((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID))
	{
		//激活框架
		ActiveGameFrame();

		//听牌判断
		if (m_bHearStatus==false)
		{
			BYTE cbChiHuRight=0;
			BYTE cbWeaveCount=m_cbWeaveCount[wMeChairID];
			pSendCard->cbActionMask|=m_GameLogic.AnalyseTingCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],cbWeaveCount,cbChiHuRight);
		}

		//动作处理
		if (pSendCard->cbActionMask!=WIK_NULL)
		{
			//获取变量
			BYTE cbActionCard=pSendCard->cbCardData;
			BYTE cbActionMask=pSendCard->cbActionMask;

			//变量定义
			tagGangCardResult GangCardResult;
			ZeroMemory(&GangCardResult,sizeof(GangCardResult));

			//杠牌判断
			if ((cbActionMask&WIK_GANG)!=0)
			{
				WORD wMeChairID=GetMeChairID();
				m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
			}

			//设置界面
			m_GameClientView.m_ControlWnd.SetControlInfo(cbActionCard,cbActionMask,GangCardResult);
			m_cbUserAction = cbActionMask;
		}
	}

	//出牌提示
	m_GameClientView.SetStatusFlag((IsLookonMode()==false)&&(m_wCurrentUser==wMeChairID),false);

	if (!IsLookonMode() && m_wCurrentUser == wMeChairID)
	{
		m_GameClientView.m_HandCardControl.UpdateCardDisable(true);
	}

	//更新界面
	m_GameClientView.RefreshGameView();

	//计算时间
	WORD wTimeCount=TIME_OPERATE_CARD;
	if ((m_bHearStatus==true)&&(m_wCurrentUser==wMeChairID))
		wTimeCount=TIME_HEAR_STATUS;

	//设置时间
	m_GameClientView.SetCurrentUser(SwitchViewChairID(m_wCurrentUser));
	SetGameClock(m_wCurrentUser,IDI_OPERATE_CARD,wTimeCount);

	return true;
}

//用户听牌
bool CGameClientEngine::OnSubListenCard(const void * pBuffer, WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_ListenCard));
	if (wDataSize!=sizeof(CMD_S_ListenCard))
		return false;

	//变量定义
	CMD_S_ListenCard * pListenCard=(CMD_S_ListenCard *)pBuffer;

	//设置界面
	WORD wViewChairID=SwitchViewChairID(pListenCard->wListenUser);
	m_GameClientView.SetUserListenStatus(wViewChairID,true);
	PlayActionSound(pListenCard->wListenUser,WIK_LISTEN);

	return true;
}

//操作提示
bool CGameClientEngine::OnSubOperateNotify(const void * pBuffer, WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_OperateNotify));
	if (wDataSize!=sizeof(CMD_S_OperateNotify))
		return false;

	//变量定义
	CMD_S_OperateNotify * pOperateNotify=(CMD_S_OperateNotify *)pBuffer;

	//用户界面
	if ((IsLookonMode()==false)&&(pOperateNotify->cbActionMask!=WIK_NULL))
	{
		//获取变量
		WORD wMeChairID=GetMeChairID();
		BYTE cbActionMask=pOperateNotify->cbActionMask;
		BYTE cbActionCard=pOperateNotify->cbActionCard;

		//变量定义
		tagGangCardResult GangCardResult;
		ZeroMemory(&GangCardResult,sizeof(GangCardResult));

		//杠牌判断
		if ((cbActionMask&WIK_GANG)!=0)
		{
			//桌面杆牌
			if ((m_wCurrentUser==INVALID_CHAIR)&&(cbActionCard!=0))
			{
				GangCardResult.cbCardCount=1;
				GangCardResult.cbCardData[0]=cbActionCard;
			}

			// 自己杆牌
			if ((m_wCurrentUser==wMeChairID)||(cbActionCard==0))
			{
				WORD wMeChairID=GetMeChairID();
				m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
			}
		}

		//设置界面
		ActiveGameFrame();
		m_GameClientView.m_ControlWnd.SetControlInfo(cbActionCard,cbActionMask,GangCardResult);
		m_cbUserAction = cbActionMask;

		//设置时间
		m_GameClientView.SetCurrentUser(INVALID_CHAIR);
		SetGameClock(GetMeChairID(),IDI_OPERATE_CARD,TIME_OPERATE_CARD);
	}

	return true;
}

//操作结果
bool CGameClientEngine::OnSubOperateResult(const void * pBuffer, WORD wDataSize)
{
	//效验消息
	ASSERT(wDataSize==sizeof(CMD_S_OperateResult));
	if (wDataSize!=sizeof(CMD_S_OperateResult))
		return false;

	//消息处理
	CMD_S_OperateResult * pOperateResult=(CMD_S_OperateResult *)pBuffer;

	//变量定义
	BYTE cbPublicCard=TRUE;
	WORD wOperateUser=pOperateResult->wOperateUser;
	BYTE cbOperateCard=pOperateResult->cbOperateCard;
	WORD wOperateViewID=SwitchViewChairID(wOperateUser);
	WORD wProviderViewID = SwitchViewChairID(pOperateResult->wProvideUser);

	//出牌变量
	if (pOperateResult->cbOperateCode!=WIK_NULL)
	{
		m_cbOutCardData=0;
		m_wOutCardUser=INVALID_CHAIR;
	}

	//设置组合
	if ((pOperateResult->cbOperateCode&WIK_GANG)!=0)
	{
		//设置变量
		m_wCurrentUser=INVALID_CHAIR;

		//组合扑克
		BYTE cbWeaveIndex=0xFF;
		for (BYTE i=0;i<m_cbWeaveCount[wOperateUser];i++)
		{
			BYTE cbWeaveKind=m_WeaveItemArray[wOperateUser][i].cbWeaveKind;
			BYTE cbCenterCard=m_WeaveItemArray[wOperateUser][i].cbCenterCard;
			if ((cbCenterCard==cbOperateCard)&&(cbWeaveKind==WIK_PENG))
			{
				cbWeaveIndex=i;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=TRUE;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult->cbOperateCode;
				m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult->wProvideUser;
				break;
			}
		}

		//组合扑克
		if (cbWeaveIndex==0xFF)
		{
			//暗杠判断
			cbPublicCard=(pOperateResult->wProvideUser==wOperateUser)?FALSE:TRUE;

			//设置扑克
			cbWeaveIndex=m_cbWeaveCount[wOperateUser]++;
			m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=cbPublicCard;
			m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard=cbOperateCard;
			m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult->cbOperateCode;
			m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult->wProvideUser;
		}

		//组合界面
		BYTE cbWeaveCard[4]={0,0,0,0},cbWeaveKind=pOperateResult->cbOperateCode;
		BYTE cbWeaveCardCount=m_GameLogic.GetWeaveCard(cbWeaveKind,cbOperateCard,cbWeaveCard);
		m_GameClientView.m_WeaveCard[wOperateViewID][cbWeaveIndex].SetCardData(cbWeaveCard,cbWeaveCardCount,0);
		m_GameClientView.m_WeaveCard[wOperateViewID][cbWeaveIndex].SetDisplayItem((cbPublicCard==TRUE)?true:false);
		//if(wOperateViewID==1 && cbWeaveIndex==1)
		//{
		//	m_GameClientView.m_WeaveCard[1][0].SetControlPoint(
		//		m_GameClientView.m_WeaveCard[1][0].GetControlXPos()+40,
		//		m_GameClientView.m_WeaveCard[1][0].GetControlYPox());
		//}
		//扑克设置
		if (GetMeChairID()==wOperateUser)
		{
			m_cbCardIndex[m_GameLogic.SwitchToCardIndex(pOperateResult->cbOperateCard)]=0;
		}

		//设置扑克
		if (GetMeChairID()==wOperateUser)
		{
			BYTE cbCardData[MAX_COUNT];
			BYTE cbCardCount=m_GameLogic.SwitchToCardData(m_cbCardIndex,cbCardData);
			m_GameClientView.m_HandCardControl.SetCardData(cbCardData,cbCardCount,0);
		}
		else
		{
			WORD wUserIndex=(wOperateViewID>=3)?2:wOperateViewID;
			BYTE cbCardCount=MAX_COUNT-m_cbWeaveCount[wOperateUser]*3;
			m_GameClientView.m_UserCard[wUserIndex].SetCardData(cbCardCount-1,false);
		}
	}
	else if (pOperateResult->cbOperateCode!=WIK_NULL)
	{
		//设置变量
		m_wCurrentUser=pOperateResult->wOperateUser;

		//设置组合
		BYTE cbWeaveIndex=m_cbWeaveCount[wOperateUser]++;
		m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbPublicCard=TRUE;
		m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbCenterCard=cbOperateCard;
		m_WeaveItemArray[wOperateUser][cbWeaveIndex].cbWeaveKind=pOperateResult->cbOperateCode;
		m_WeaveItemArray[wOperateUser][cbWeaveIndex].wProvideUser=pOperateResult->wProvideUser;

		//组合界面
		BYTE cbWeaveCard[4]={0,0,0,0},cbWeaveKind=pOperateResult->cbOperateCode;
		BYTE cbWeaveCardCount=m_GameLogic.GetWeaveCard(cbWeaveKind,cbOperateCard,cbWeaveCard);
		m_GameClientView.m_WeaveCard[wOperateViewID][cbWeaveIndex].SetCardData(cbWeaveCard,cbWeaveCardCount,cbWeaveKind==WIK_PENG?0:pOperateResult->cbOperateCard);
		m_GameClientView.m_WeaveCard[wOperateViewID][cbWeaveIndex].SetDirectionCardPos(3-(wOperateViewID-wProviderViewID+4)%4);

		//删除扑克
		if (GetMeChairID()==wOperateUser)
		{
			m_GameLogic.RemoveCard(cbWeaveCard,cbWeaveCardCount,&cbOperateCard,1);
			m_GameLogic.RemoveCard(m_cbCardIndex,cbWeaveCard,cbWeaveCardCount-1);
		}

		//设置扑克
		if (GetMeChairID()==wOperateUser)
		{
			BYTE cbCardData[MAX_COUNT];
			BYTE cbCardCount=m_GameLogic.SwitchToCardData(m_cbCardIndex,cbCardData);
			m_GameClientView.m_HandCardControl.SetCardData(cbCardData,cbCardCount-1,cbCardData[cbCardCount-1]);
		}
		else
		{
			WORD wUserIndex=(wOperateViewID>=3)?2:wOperateViewID;
			BYTE cbCardCount=MAX_COUNT-m_cbWeaveCount[wOperateUser]*3;
			m_GameClientView.m_UserCard[wUserIndex].SetCardData(cbCardCount-1,true);
		}
	}

	//设置界面
	m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);
	m_GameClientView.SetUserAction(wOperateViewID,pOperateResult->cbOperateCode);
	m_GameClientView.SetStatusFlag((IsLookonMode()==false)&&(m_wCurrentUser==GetMeChairID()),false);

	//更新界面
	m_GameClientView.RefreshGameView();

	//环境设置
	PlayActionSound(pOperateResult->wOperateUser,pOperateResult->cbOperateCode);

	//设置时间
	if (m_wCurrentUser!=INVALID_CHAIR)
	{
		//听牌判断
		if ((IsLookonMode()==false)&&(m_bHearStatus==false)&&(m_wCurrentUser==GetMeChairID()))
		{
			m_GameClientView.m_HandCardControl.UpdateCardDisable(true);
			//听牌判断
			BYTE cbChiHuRight=0;
			WORD wMeChairID=GetMeChairID();
			BYTE cbWeaveCount=m_cbWeaveCount[wMeChairID];
			BYTE cbActionMask=m_GameLogic.AnalyseTingCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],cbWeaveCount,cbChiHuRight);

			//操作提示
			if (cbActionMask!=NULL)
			{
				tagGangCardResult GangCardResult;
				ZeroMemory(&GangCardResult,sizeof(GangCardResult));
				m_GameClientView.m_ControlWnd.SetControlInfo(0,cbActionMask,GangCardResult);
				m_cbUserAction = cbActionMask;
			}
		}

		//计算时间
		WORD wTimeCount=TIME_OPERATE_CARD;
		if ((m_bHearStatus==true)&&(m_wCurrentUser==GetMeChairID())) wTimeCount=TIME_HEAR_STATUS;

		//设置时间
		m_GameClientView.SetCurrentUser(SwitchViewChairID(m_wCurrentUser));
		SetGameClock(m_wCurrentUser,IDI_OPERATE_CARD,wTimeCount);
	}

	return true;
}

//游戏结束
bool CGameClientEngine::OnSubGameEnd(const void * pBuffer, WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_GameEnd));
	if (wDataSize!=sizeof(CMD_S_GameEnd)) return false;

	//消息处理
	CMD_S_GameEnd * pGameEnd=(CMD_S_GameEnd *)pBuffer;

	//设置状态
	SetGameStatus(GS_MJ_FREE);
	m_GameClientView.SetStatusFlag(false,false);

	//删除定时器
	KillGameClock(IDI_OPERATE_CARD);

	//设置控件
	m_GameClientView.SetStatusFlag(false,false);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);
	m_GameClientView.m_btMaiCancel.ShowWindow(SW_HIDE);
	m_GameClientView.m_btDingCancel.ShowWindow(SW_HIDE);
	m_GameClientView.m_btMaiDi.ShowWindow(SW_HIDE);
	m_GameClientView.m_btDingDi.ShowWindow(SW_HIDE);
	m_GameClientView.m_HandCardControl.SetPositively(false);

	////结束设置  荒庄
	//if (pGameEnd->cbChiHuCard==0)
	//{
	//	DeductionTableCard(true);
	//	m_GameClientView.SetHuangZhuang(true);
	//}

	//设置扑克
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_GameClientView.m_WeaveCard[i][0].SetDisplayItem(true);
		m_GameClientView.m_WeaveCard[i][1].SetDisplayItem(true);
		m_GameClientView.m_WeaveCard[i][2].SetDisplayItem(true);
		m_GameClientView.m_WeaveCard[i][3].SetDisplayItem(true);
		m_GameClientView.m_WeaveCard[i][4].SetDisplayItem(true);
	}

	//变量定义
	tagScoreInfo ScoreInfo;
	tagWeaveInfo WeaveInfo;
	ZeroMemory(&ScoreInfo,sizeof(ScoreInfo));
	ZeroMemory(&WeaveInfo,sizeof(WeaveInfo));

	//成绩变量
	ScoreInfo.wBankerUser=m_wBankerUser;
	ScoreInfo.wProvideUser=pGameEnd->wProvideUser;
	ScoreInfo.cbProvideCard=pGameEnd->cbProvideCard;

	//设置积分
	//CString strTemp ,strEnd = _T("\n");
	m_pIStringMessage->InsertNormalString(TEXT("本局结算信息:"));
	TCHAR szBuffer[512]=TEXT("");
	_sntprintf(szBuffer,CountArray(szBuffer),TEXT("%-14s%-10s%-6s\n"),TEXT("用户昵称"),TEXT("成绩"),TEXT("财神"));
	m_pIStringMessage->InsertNormalString(szBuffer);
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
//		strTemp = TEXT("");
		IClientUserItem * pUserData=GetTableUserItem(i);
		ScoreInfo.byDingDi[i] = pGameEnd->byDingDi[i];
		//胡牌类型
		ScoreInfo.dwChiHuKind[i]=pGameEnd->dwChiHuKind[i];
		ScoreInfo.dwChiHuRight[i]=pGameEnd->dwChiHuRight[i];

		//设置成绩
		ScoreInfo.lGameScore[i]=pGameEnd->lGameScore[i];
		ScoreInfo.lGodsScore[i]=pGameEnd->lGodsScore[i];
		lstrcpyn(ScoreInfo.szUserName[i],pUserData->GetNickName(),CountArray(ScoreInfo.szUserName[i]));

		CString str;
		str.Format(TEXT("%s"),pUserData->GetNickName());
		DWORD  le0 = CStringA(str).GetLength();

		CString strFormat;
		strFormat.Format(TEXT("%%-%ds%%+-12I64d%%+-8I64d"),18-(le0-str.GetLength()));

		_sntprintf(szBuffer,CountArray(szBuffer),strFormat,pUserData->GetNickName(),pGameEnd->lGameScore[i],pGameEnd->lGodsScore[i]);
		m_pIStringMessage->InsertNormalString(szBuffer);


		/*if(pGameEnd->lGameScore[i]>0)
			strTemp.Format(_T("%s：\t\t %+ld "),pUserData->GetNickName(),pGameEnd->lGameScore[i]);
		else
			strTemp.Format(_T("%s：\t\t %ld "),pUserData->GetNickName(),pGameEnd->lGameScore[i]);
		strEnd += strTemp;

		if(pGameEnd->lGameScore[i]>0)
			strTemp.Format(_T("\t\t财神：%+ld\n"), pGameEnd->lGodsScore[i]);
		else
			strTemp.Format(_T("\t\t财神：%ld\n"), pGameEnd->lGodsScore[i]);
		strEnd += strTemp;*/

		//胡牌扑克
		if ((ScoreInfo.cbCardCount==0)&&(pGameEnd->dwChiHuKind[i]!=CHK_NULL))
		{
			// 组合扑克
			WeaveInfo.cbWeaveCount=m_cbWeaveCount[i];
			for (BYTE j=0;j<WeaveInfo.cbWeaveCount;j++)
			{
				BYTE cbWeaveKind=m_WeaveItemArray[i][j].cbWeaveKind;
				BYTE cbCenterCard=m_WeaveItemArray[i][j].cbCenterCard;
				WeaveInfo.cbPublicWeave[j]=m_WeaveItemArray[i][j].cbPublicCard;
				WeaveInfo.cbCardCount[j]=m_GameLogic.GetWeaveCard(cbWeaveKind,cbCenterCard,WeaveInfo.cbCardData[j]);
			}

			//设置扑克
			ScoreInfo.cbCardCount=pGameEnd->cbCardCount[i];
			CopyMemory(ScoreInfo.cbCardData,&pGameEnd->cbCardData[i],ScoreInfo.cbCardCount*sizeof(BYTE));

			//提取胡牌
			for (BYTE j=0;j<ScoreInfo.cbCardCount;j++)
			{
				if ((ScoreInfo.cbCardData[j]==pGameEnd->cbProvideCard) && (j<ScoreInfo.cbCardCount-1))
				{
					MoveMemory(&ScoreInfo.cbCardData[j],&ScoreInfo.cbCardData[j+1],(ScoreInfo.cbCardCount-j-1)*sizeof(BYTE));
					ScoreInfo.cbCardData[ScoreInfo.cbCardCount-1]=pGameEnd->cbProvideCard;
					break;
				}
			}
		}
	}

	//消息积分
	//m_pIStringMessage->InsertSystemString((LPCTSTR)strEnd);

	//成绩界面
	m_GameClientView.m_ScoreControl.SetScoreInfo(ScoreInfo,WeaveInfo,GetMeChairID());

	int iHuType=m_GameClientView.m_ScoreControl.GetHardSoftHu();
	//用户扑克
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		WORD wViewChairID=SwitchViewChairID(i);
		if (pGameEnd->dwChiHuKind[i]!=CHK_NULL) m_GameClientView.SetUserAction(wViewChairID,WIK_CHI_HU);
		m_GameClientView.m_TableCard[wViewChairID].SetCardData(pGameEnd->cbCardData[i],pGameEnd->cbCardCount[i]);
	}

	//设置扑克
	m_GameClientView.m_UserCard[0].SetCardData(0,false);
	m_GameClientView.m_UserCard[1].SetCardData(0,false);
	m_GameClientView.m_HandCardControl.SetCardData(NULL,0,0);

	//播放声音
	__int64 lScore=pGameEnd->lGameScore[GetMeChairID()];
	IClientUserItem* pUserData = GetTableUserItem(1);
	bool bGirl = ((pUserData->GetGender()==GENDER_MANKIND) ?  false:true);
	switch(iHuType)
	{
	case 1://软胡
		if(bGirl)
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_HU_RUAN"));
		else
			PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_HU_RUAN"));
		break;
	case 2://硬胡
		if(bGirl)
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_HU_YING"));
		else
			PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_HU_YING"));
		break;
	case 3://双翻
		if(bGirl)
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_FANBEI"));
		else
			PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_FANBEI"));
		break;
	default:
		if (lScore>0L)
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_WIN"));
		else if (lScore<0L)
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_LOST"));
		else
			PlayGameSound(AfxGetInstanceHandle(),TEXT("GAME_END"));
		break;
	}
	//设置界面
	if (IsLookonMode()==false)
	{
		m_GameClientView.m_btStart.ShowWindow(SW_SHOW);
		m_GameClientView.SetCurrentUser(INVALID_CHAIR);
		SetGameClock(GetMeChairID(),IDI_START_GAME,TIME_START_GAME);
	}

	//取消托管
	if(m_bStustee)
		OnStusteeControl(0,0);

	//更新界面
	m_GameClientView.RefreshGameView();
	return true;
}

//用户托管
bool CGameClientEngine::OnSubTrustee(const void * pBuffer,WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_Trustee));
	if (wDataSize!=sizeof(CMD_S_Trustee)) return false;

	//消息处理
	CMD_S_Trustee * pTrustee=(CMD_S_Trustee *)pBuffer;
	m_GameClientView.SetTrustee(SwitchViewChairID(pTrustee->wChairID),pTrustee->bTrustee);
	if ((IsLookonMode()==true)||(pTrustee->wChairID!=GetMeChairID()))
	{
		IClientUserItem * pUserData=GetTableUserItem(pTrustee->wChairID);
		if (pUserData==NULL) return true;
		TCHAR szBuffer[256];
		if(pTrustee->bTrustee==true)
			_sntprintf(szBuffer,sizeof(szBuffer),TEXT("玩家[%s]选择了托管功能."),pUserData->GetNickName());
		else
			_sntprintf(szBuffer,sizeof(szBuffer),TEXT("玩家[%s]取消了托管功能."),pUserData->GetNickName());
		m_pIStringMessage->InsertSystemString(szBuffer);
	}

	return true;
}

// 庄家买底
bool CGameClientEngine::OnSubDingDi(const void * pBuffer,WORD wDataSize)
{
	//效验数据
	ASSERT(wDataSize==sizeof(CMD_S_DingDi));
	if (wDataSize!=sizeof(CMD_S_DingDi)) return false;

	m_wCurrentUser = INVALID_CHAIR;
	KillGameClock(IDI_DINGDI_CARD);
	CMD_S_DingDi *pDingDi = (CMD_S_DingDi *)pBuffer;
	if (m_wBankerUser == pDingDi->wChairID)
	{
		WORD wMeChair = GetMeChairID();
		// 设置显示
		if (m_wBankerUser == wMeChair)
		{
			m_GameClientView.SetCenterText(TEXT("等待闲家顶底……"));
		}
		else
		{
			TCHAR szMsg[MAX_PATH]={0};
			_sntprintf(szMsg, sizeof(szMsg), TEXT(""));// TEXT("目前底数为：%u"), pDingDi->byMaiDi*2);
			m_GameClientView.SetCenterText(szMsg);
			if (pDingDi->bDingDi && !IsLookonMode())
			{
				ActiveGameFrame();
				m_GameClientView.m_btDingDi.ShowWindow(SW_SHOW);
				m_GameClientView.m_btDingCancel.ShowWindow(SW_SHOW);
				m_GameClientView.m_btDingDi.EnableWindow(TRUE);
				m_GameClientView.m_btDingCancel.EnableWindow(TRUE);
				m_wCurrentUser = wMeChair;
			}
		}
		m_GameClientView.SetCurrentUser(SwitchViewChairID(wMeChair));
		SetGameClock(wMeChair, IDI_DINGDI_CARD, TIME_OPERATE_CARD);
	}
	return true;
}

//播放出牌声音
void CGameClientEngine::PlayCardSound(WORD wChairID, BYTE cbCardData)
{
	if(m_GameLogic.IsValidCard(cbCardData) == false)
	{
		return;
	}
	if(wChairID < 0 || wChairID > 3)
	{
		return;
	}

	//判断性别
	IClientUserItem* pUserData = GetTableUserItem(wChairID);
	if(pUserData == 0)
	{
		assert(0 && "得不到玩家信息");
		return;
	}
	bool bGirl = ((pUserData->GetGender()!=GENDER_MANKIND) ? true : false);
	BYTE cbType= (cbCardData & MASK_COLOR);
	BYTE cbValue= (cbCardData & MASK_VALUE);
	if(cbType==0x30 && cbValue==7)//白板，打财神的牌
	{
		BYTE cbGods=m_GameClientView.GetGodsCard();
		cbType=(cbGods & MASK_COLOR);
		cbValue=(cbGods & MASK_VALUE);
	}
	CString strSoundName;
	switch(cbType)
	{
	case 0X30:	//风
		{
			switch(cbValue)
			{
			case 1:
				{
					strSoundName = _T("F_1");
					break;
				}
			case 2:
				{
					strSoundName = _T("F_2");
					break;
				}
			case 3:
				{
					strSoundName = _T("F_3");
					break;
				}
			case 4:
				{
					strSoundName = _T("F_4");
					break;
				}
			case 5:
				{
					strSoundName = _T("F_5");
					break;
				}
			case 6:
				{
					strSoundName = _T("F_6");
					break;
				}
			case 7:
				{
					strSoundName = _T("F_7");
					break;
				}
			default:
				{
					strSoundName=_T("BU_HUA");
				}

			}
			break;
		}
	case 0X20:	//筒
		{
			strSoundName.Format(_T("T_%d"), cbValue);
			break;
		}

	case 0X10:	//索
		{
			strSoundName.Format(_T("S_%d"), cbValue);
			break;
		}
	case 0X00:	//万
		{
			strSoundName.Format(_T("W_%d"), cbValue);
			break;
		}
	}

	if(!bGirl)
	{
		strSoundName = _T("BOY_") +strSoundName;
	}
	else
	{
		strSoundName = _T("GIRL_") + strSoundName;
	}
	PlayGameSound(AfxGetInstanceHandle(), strSoundName);
}
//播放声音
void CGameClientEngine::PlayActionSound(WORD wChairID,BYTE cbAction)
{
	//判断性别
	IClientUserItem* pUserData = GetTableUserItem(wChairID);
	if(pUserData == 0)
	{
		assert(0 && "得不到玩家信息");
		return;
	}
	if(wChairID < 0 || wChairID > 3)
	{
		return;
	}
	bool bGirl = ((pUserData->GetGender()!=GENDER_MANKIND) ? true : false);

	switch (cbAction)
	{
	case WIK_NULL:		//取消
		{
			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_OUT_CARD"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_OUT_CARD"));
			break;
		}
	case WIK_LEFT:
	case WIK_CENTER:
	case WIK_RIGHT:		//上牌
		{
			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_CHI"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_CHI"));
			break;
		}
	case WIK_PENG:		//碰牌
		{
			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_PENG"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_PENG"));
			break;
		}
	case WIK_GANG:		//杠牌
		{
			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_GANG"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_GANG"));
			break;
		}
	case WIK_CHI_HU:	//吃胡
		{

			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_CHI_HU"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_CHI_HU"));
			break;
		}
	case WIK_LISTEN:	//听牌
		{
			if(!bGirl)
				PlayGameSound(AfxGetInstanceHandle(),TEXT("BOY_TING"));
			else
				PlayGameSound(AfxGetInstanceHandle(),TEXT("GIRL_TING"));
		}
	}

	return;
}
//出牌判断
bool CGameClientEngine::VerdictOutCard(BYTE cbCardData)
{
	//听牌判断
	if ((m_bHearStatus==true)||(m_bWillHearStatus==true))
	{
		//变量定义
		tagChiHuResult ChiHuResult;
		WORD wMeChairID=GetMeChairID();
		BYTE cbWeaveCount=m_cbWeaveCount[wMeChairID];

		//构造扑克
		BYTE cbCardIndexTemp[MAX_INDEX];
		CopyMemory(cbCardIndexTemp,m_cbCardIndex,sizeof(cbCardIndexTemp));

		//删除扑克
		m_GameLogic.RemoveCard(cbCardIndexTemp,cbCardData);

		//听牌判断
		for (BYTE i=0;i<MAX_INDEX;i++)
		{
			//胡牌分析
			BYTE wChiHuRight=0;
			BYTE cbCurrentCard=m_GameLogic.SwitchToCardData(i);
			BYTE cbHuCardKind=m_GameLogic.AnalyseChiHuCard(cbCardIndexTemp,m_WeaveItemArray[wMeChairID],cbWeaveCount,cbCurrentCard,wChiHuRight,ChiHuResult);

			//结果判断
			if (cbHuCardKind!=CHK_NULL)
				break;
		}

		//听牌判断
		return (i!=MAX_INDEX);
	}

	return true;
}


//扣除扑克
void CGameClientEngine::DeductionTableCard(bool bHeadCard)
{
	if (bHeadCard==true)
	{
		//切换索引
		BYTE cbHeapCount=m_cbHeapCardInfo[m_wHeapHand][0]+m_cbHeapCardInfo[m_wHeapHand][1];

		if (cbHeapCount==HEAP_FULL_COUNT)
			m_wHeapHand=(m_wHeapHand+1)%CountArray(m_cbHeapCardInfo);

		//减少扑克
		m_cbLeftCardCount--;
		m_cbHeapCardInfo[m_wHeapHand][0]++;

		//堆立扑克
		//WORD wHeapViewID=SwitchViewChairID(m_wHeapHand);
		WORD wHeapViewID=SwitchHeapViewChairID(m_wHeapHand); //m_wHeapHand+6-GetMeChairID()*2)%4;
		//WORD wHeapViewID=(m_wHeapHand+6-GetMeChairID()*2)%4;
		//if(wHeapViewID==2)wHeapViewID=1;
		//else if(wHeapViewID==1)wHeapViewID=2;;
		WORD wMinusHeadCount=m_cbHeapCardInfo[m_wHeapHand][0];
		WORD wMinusLastCount=m_cbHeapCardInfo[m_wHeapHand][1];
		m_GameClientView.m_HeapCard[wHeapViewID].SetCardData(wMinusHeadCount,wMinusLastCount,HEAP_FULL_COUNT);
	}
	else
	{
		//切换索引
		BYTE cbHeapCount=m_cbHeapCardInfo[m_wHeapTail][0]+m_cbHeapCardInfo[m_wHeapTail][1];
		if (cbHeapCount==HEAP_FULL_COUNT)
			m_wHeapTail=(m_wHeapTail+1)%CountArray(m_cbHeapCardInfo);

		//减少扑克
		m_cbLeftCardCount--;
		m_cbHeapCardInfo[m_wHeapTail][1]++;

		//堆立扑克
		WORD wHeapViewID=SwitchHeapViewChairID(m_wHeapTail);
		//WORD wHeapViewID=SwitchViewChairID(m_wHeapTail);
		WORD wMinusHeadCount=m_cbHeapCardInfo[m_wHeapTail][0];
		WORD wMinusLastCount=m_cbHeapCardInfo[m_wHeapTail][1];
		m_GameClientView.m_HeapCard[wHeapViewID].SetCardData(wMinusHeadCount,wMinusLastCount,HEAP_FULL_COUNT);
	}

	return;
}

//显示控制
bool CGameClientEngine::ShowOperateControl(BYTE cbUserAction, BYTE cbActionCard)
{
	//变量定义
	tagGangCardResult GangCardResult;
	ZeroMemory(&GangCardResult,sizeof(GangCardResult));

	//杠牌判断
	if ((cbUserAction&WIK_GANG)!=0)
	{
		//桌面杆牌
		if (cbActionCard!=0)
		{
			GangCardResult.cbCardCount=1;
			GangCardResult.cbCardData[0]=cbActionCard;
		}

		//自己杆牌
		if (cbActionCard==0)
		{
			WORD wMeChairID=GetMeChairID();
			m_GameLogic.AnalyseGangCard(m_cbCardIndex,m_WeaveItemArray[wMeChairID],m_cbWeaveCount[wMeChairID],GangCardResult);
		}
	}

	//显示界面
	if (IsLookonMode()==false)
	{
		m_GameClientView.m_ControlWnd.SetControlInfo(cbActionCard,cbUserAction,GangCardResult);
		m_cbUserAction = cbUserAction;
	}

	return true;
}

//开始按钮
LRESULT CGameClientEngine::OnStart(WPARAM wParam, LPARAM lParam)
{
	//if(IsFreeze())
	//{
	//	OnCancel();
	//	return 0;
	//}
	//环境设置
	KillGameClock(IDI_START_GAME);
	m_GameClientView.m_btStart.ShowWindow(SW_HIDE);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);
	m_GameClientView.m_ScoreControl.RestorationData();

	//设置界面
	m_GameClientView.SetDiscUser(INVALID_CHAIR);
	m_GameClientView.SetHuangZhuang(false);
	m_GameClientView.SetStatusFlag(false,false);
	m_GameClientView.SetBankerUser(INVALID_CHAIR);
	m_GameClientView.SetUserAction(INVALID_CHAIR,0);
	m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
	m_GameClientView.SetUserListenStatus(INVALID_CHAIR,false);

	//扑克设置
	m_GameClientView.m_UserCard[0].SetCardData(0,false);
	m_GameClientView.m_UserCard[1].SetCardData(0,false);
	m_GameClientView.m_HandCardControl.SetCardData(NULL,0,0);
	m_GameClientView.SetGodsCard(0x00);
	m_GameClientView.m_HandCardControl.SetGodsCard(0x00);
	m_GameClientView.SetDingMaiValue(NULL);


	//扑克设置
	for (WORD i=0;i<GAME_PLAYER;i++)
	{
		m_GameClientView.m_TableCard[i].SetCardData(NULL,0);
		m_GameClientView.m_DiscardCard[i].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][0].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][1].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][2].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][3].SetCardData(NULL,0);
		m_GameClientView.m_WeaveCard[i][4].SetCardData(NULL,0);
	}

	//堆立扑克
	for (WORD i=0;i<4;i++)
	{
		m_cbHeapCardInfo[i][0]=0;
		m_cbHeapCardInfo[i][1]=0;
		m_GameClientView.m_HeapCard[i].SetGodsCard(0x00,0x00,0x00);
		m_GameClientView.m_HeapCard[i].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
	}

	//状态变量
	m_bHearStatus=false;
	m_bWillHearStatus=false;

	//游戏变量
	m_wCurrentUser=INVALID_CHAIR;

	//出牌信息
	m_cbOutCardData=0;
	m_wOutCardUser=INVALID_CHAIR;
	ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
	ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

	//组合扑克
	ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
	ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));

	//堆立扑克
	m_wHeapHand=0;
	m_wHeapTail=0;
	ZeroMemory(m_cbHeapCardInfo,sizeof(m_cbHeapCardInfo));

	//扑克变量
	m_cbLeftCardCount=0;
	ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));

	//发送消息
	SendUserReady(NULL,0);

	return 0;
}

LRESULT CGameClientEngine::OnOutInvalidCard(WPARAM wParam,LPARAM lParam)
{
	if (GS_MJ_PLAY != GetGameStatus())
	{
		return 0;
	}

	//出牌判断
	if ((IsLookonMode()==true)||(m_wCurrentUser!=GetMeChairID()))
		return 0;

	m_GameClientView.m_bTipSingle=true;
	m_GameClientView.SetTimer(102/*IDI_TIP_SINGLE*/,2500,NULL);
	m_GameClientView.RefreshGameView();

	return 0;
}
//出牌操作
LRESULT CGameClientEngine::OnOutCard(WPARAM wParam, LPARAM lParam)
{
	KillGameClock(IDI_OPERATE_CARD);

	if (GS_MJ_PLAY != GetGameStatus())
	{
		return 0;
	}

	//出牌判断
	if ((IsLookonMode()==true)||(m_wCurrentUser!=GetMeChairID()))
		return 0;

	//听牌判断
	if (((m_bHearStatus==true)||(m_bWillHearStatus==true))&&(VerdictOutCard((BYTE)wParam)==false))
	{
		m_pIStringMessage->InsertSystemString(TEXT("出此牌不符合游戏规则!"));
		return 0;
	}

	//听牌设置
	if (m_bWillHearStatus==true)
	{
		m_bHearStatus=true;
		m_bWillHearStatus=false;
	}

	//设置变量
	m_wCurrentUser=INVALID_CHAIR;
	BYTE cbOutCardData=(BYTE)wParam;
	m_GameLogic.RemoveCard(m_cbCardIndex,cbOutCardData);

	//设置扑克
	BYTE cbCardData[MAX_COUNT];
	BYTE cbCardCount=m_GameLogic.SwitchToCardData(m_cbCardIndex,cbCardData);
	m_GameClientView.m_HandCardControl.SetCardData(cbCardData,cbCardCount,0);

	//设置界面
	KillGameClock(IDI_OPERATE_CARD);
	m_GameClientView.RefreshGameView();
	m_GameClientView.SetStatusFlag(false,false);
	m_GameClientView.SetUserAction(INVALID_CHAIR,0);
	m_GameClientView.SetOutCardInfo(1,cbOutCardData);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);

	//播放声音
	PlayCardSound(GetMeChairID(),cbOutCardData);

	//发送数据
	CMD_C_OutCard OutCard;
	OutCard.cbCardData=cbOutCardData;
	SendSocketData(SUB_C_OUT_CARD,&OutCard,sizeof(OutCard));

	return 0;
}

//听牌操作
LRESULT CGameClientEngine::OnListenCard(WPARAM wParam, LPARAM lParam)
{
	//设置变量
	//m_bWillHearStatus=true;

	////提示消息
	//m_pIStringMessage->InsertSystemString(TEXT("请选择胡口牌"));

	////设置界面
	//m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);

	////发送消息
	//SendSocketData(SUB_C_LISTEN_CARD);

	return 0;
}

//扑克操作
LRESULT CGameClientEngine::OnCardOperate(WPARAM wParam, LPARAM lParam)
{
	//变量定义
	BYTE cbOperateCode=(BYTE)(wParam);
	BYTE cbOperateCard=(BYTE)(LOWORD(lParam));

	//状态判断
	if ((m_wCurrentUser==GetMeChairID())&&(cbOperateCode==WIK_NULL))
	{
		m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);
		return 0;
	}

	//删除时间
	KillGameClock(IDI_OPERATE_CARD);

	//环境设置
	m_GameClientView.SetStatusFlag(false,true);
	m_GameClientView.m_ControlWnd.ShowWindow(SW_HIDE);

	//发送命令
	CMD_C_OperateCard OperateCard;
	OperateCard.cbOperateCode=cbOperateCode;
	OperateCard.cbOperateCard=cbOperateCard;
	SendSocketData(SUB_C_OPERATE_CARD,&OperateCard,sizeof(OperateCard));

	return 0;
}
//拖管控制
LRESULT CGameClientEngine::OnStusteeControl(WPARAM wParam, LPARAM lParam)
{
	//设置变量
	m_wTimeOutCount=0;

	//设置状态
	if (m_bStustee==true)
	{
		m_bStustee=false;
		m_GameClientView.m_btStusteeControl.SetButtonImage(IDB_BT_START_TRUSTEE,AfxGetInstanceHandle(),false,false);
		m_pIStringMessage->InsertSystemString(_T("您取消了托管功能."));
		CMD_C_Trustee Trustee;
		Trustee.bTrustee = false;
		SendSocketData(SUB_C_TRUSTEE,&Trustee,sizeof(Trustee));

	}
	else
	{
		m_bStustee=true;
		m_GameClientView.m_btStusteeControl.SetButtonImage(IDB_BT_STOP_TRUSTEE,AfxGetInstanceHandle(),false,false);
		m_pIStringMessage->InsertSystemString(_T("您选择了托管功能."));
		CMD_C_Trustee Trustee;
		Trustee.bTrustee = true;
		SendSocketData(SUB_C_TRUSTEE,&Trustee,sizeof(Trustee));

	}

	return 0;
}

LRESULT CGameClientEngine::OnDingDi(WPARAM wParam, LPARAM lParam)
{
	m_GameClientView.m_btMaiDi.ShowWindow(SW_HIDE);
	m_GameClientView.m_btDingDi.ShowWindow(SW_HIDE);
	m_GameClientView.m_btMaiCancel.ShowWindow(SW_HIDE);
	m_GameClientView.m_btDingCancel.ShowWindow(SW_HIDE);
	if (GS_MJ_MAIDI != GetGameStatus())
	{
		return 0;
	}
	m_wCurrentUser = INVALID_CHAIR;
	// 发送顶底消息
	CMD_C_DingDi DingDi;
	DingDi.byDingDi = (2==wParam)?0x02:0x01;
	SendSocketData(SUB_C_DINGDI,&DingDi,sizeof(DingDi));
	return 0;
}
//////////////////////////////////////////////////////////////////////////

bool CGameClientEngine::IsFreeze(void)
{
	/*if(pServerAttribute->wGameGenre==GAME_GENRE_GOLD)
	{
		tagUserData const *pMeUserData = GetTableUserItem( GetMeChairID());
		if(pMeUserData->bFreeze)
		{
			ShowInformation(TEXT("对不起，您的帐户已被冻结，不能开始游戏！\n\n请与管理员联系。"),0,MB_ICONINFORMATION);
			return true;
		}
	}*/
	return false;
}

LRESULT CGameClientEngine::OnDispatchCard(WPARAM wParam, LPARAM lParam)
{
	KillGameClock(IDI_DINGDI_CARD);
	m_GameClientView.StopSicboAnim();
	++ m_bySicboAnimCount;
	if (1 == m_bySicboAnimCount)
	{
		CMD_S_GamePlay *pGamePlay = &m_sGamePlay;
		if (0 == wParam)
		{
			// 打第二次骰子
			BYTE bySicbo[2] = {HIBYTE(pGamePlay->wSiceCount3), LOBYTE(pGamePlay->wSiceCount3)};
			m_GameClientView.StartSicboAnim(bySicbo);
		}
		return 0;
	}
	else if (2 == m_bySicboAnimCount)
	{
		// 显示出牌
		CMD_S_GamePlay *pGamePlay = &m_sGamePlay;

		WORD wMeChairID=GetMeChairID();
		bool bPlayerMode=(IsLookonMode()==false);

		m_wCurrentUser=pGamePlay->wCurrentUser;
		m_GameLogic.SetGodsCard(pGamePlay->byGodsCardData);
		m_GameClientView.SetGodsCard(pGamePlay->byGodsCardData);

		ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));

		//设置扑克
		BYTE cbCardCount=(wMeChairID==m_wBankerUser)?MAX_COUNT:(MAX_COUNT-1);
		m_GameLogic.SwitchToCardIndex(pGamePlay->cbCardData[wMeChairID],cbCardCount,m_cbCardIndex);
		// 换算出财神牌的位置
		BYTE byCount = HEAP_FULL_COUNT - m_cbHeapCardInfo[m_wHeapTail][1];
		BYTE bySicbo = HIBYTE(pGamePlay->wSiceCount3) + LOBYTE(pGamePlay->wSiceCount3);
		BYTE byChairID = (BYTE) wMeChairID;
		if (byCount >= bySicbo)
		{
			byChairID = (BYTE) m_wHeapTail;
		}
		else
		{
			byChairID = (m_wHeapTail + 4 - 1)%4;
			bySicbo =  bySicbo - byCount;
		}
		//转换椅子
		//WORD wViewChairID=(byChairID+6-wMeChairID*2)%4;
		WORD wViewChairID=SwitchHeapViewChairID(byChairID);
		m_GameClientView.m_HeapCard[wViewChairID].SetGodsCard(pGamePlay->byGodsCardData,bySicbo, m_cbHeapCardInfo[byChairID][1]);

		//更新界面
		m_GameClientView.SetCenterText(TEXT(""));
		// 发牌，并打第三次骰子
		if (0 == wParam)
		{
			BYTE bySicbo[2] = {HIBYTE(pGamePlay->wSiceCount2), LOBYTE(pGamePlay->wSiceCount2)};
			m_GameClientView.StartSicboAnim(bySicbo);
		}
		return 0;
	}
	else //if((3 == m_bySicboAnimCount)
	{
		//设置变量
		CMD_S_GamePlay *pGamePlay = &m_sGamePlay;
		m_bHearStatus=false;
		m_bWillHearStatus=false;
		m_cbLeftCardCount=MAX_REPERTORY-GAME_PLAYER*(MAX_COUNT-1)-1;

		m_GameClientView.m_HandCardControl.SetGodsCard(pGamePlay->byGodsCardData);

		//出牌信息
		m_cbOutCardData=0;
		m_wOutCardUser=INVALID_CHAIR;
		ZeroMemory(m_cbDiscardCard,sizeof(m_cbDiscardCard));
		ZeroMemory(m_cbDiscardCount,sizeof(m_cbDiscardCount));

		//组合扑克
		ZeroMemory(m_cbWeaveCount,sizeof(m_cbWeaveCount));
		ZeroMemory(m_WeaveItemArray,sizeof(m_WeaveItemArray));
		ZeroMemory(m_cbCardIndex,sizeof(m_cbCardIndex));

		WORD wMeChairID=GetMeChairID();

		//设置扑克
		BYTE cbCardCount=(wMeChairID==m_wBankerUser)?MAX_COUNT:(MAX_COUNT-1);
		m_GameLogic.SwitchToCardIndex(pGamePlay->cbCardData[wMeChairID],cbCardCount,m_cbCardIndex);

		//设置界面
		bool bPlayerMode=(IsLookonMode()==false);
		m_GameClientView.SetUserListenStatus(INVALID_CHAIR,false);
		m_GameClientView.m_HandCardControl.SetPositively(false);
		m_GameClientView.SetBankerUser(SwitchViewChairID(m_wBankerUser));
		m_GameClientView.SetDiscUser(INVALID_CHAIR);

		//旁观界面
		if (bPlayerMode==false)
		{
			m_GameClientView.SetHuangZhuang(false);
			m_GameClientView.SetStatusFlag(false,false);
			m_GameClientView.SetUserAction(INVALID_CHAIR,0);
			m_GameClientView.SetOutCardInfo(INVALID_CHAIR,0);
		}

		for (WORD i=0;i<4;i++)
		{
			m_cbHeapCardInfo[i][0]=0;
			m_cbHeapCardInfo[i][1]=0;
		}

		// 分发扑克
		// 第一把骰子的玩家 门前开始数牌
		BYTE cbSiceFirst=(HIBYTE(pGamePlay->wSiceCount1) + LOBYTE(pGamePlay->wSiceCount1)-1)%4;
		WORD wTakeChairID = (m_wBankerUser*2 + 4 - cbSiceFirst)%4;
		BYTE cbSiceSecond= HIBYTE(pGamePlay->wSiceCount2) + LOBYTE(pGamePlay->wSiceCount2)
			+ (HIBYTE(pGamePlay->wSiceCount1) + LOBYTE(pGamePlay->wSiceCount1));
		if ((cbSiceSecond*2)>HEAP_FULL_COUNT)
		{
			wTakeChairID = (wTakeChairID + 1)%4;
			cbSiceSecond = cbSiceSecond-(HEAP_FULL_COUNT/2);
		}
		m_wHeapTail = wTakeChairID%4;
		//////////////////////////////////////////////////////////////////////////
		BYTE cbTakeCount=(MAX_COUNT-1)*2+1;

		for (WORD i=0;i<2;i++)
		{
			//计算数目
			BYTE cbValidCount=HEAP_FULL_COUNT-m_cbHeapCardInfo[wTakeChairID][1]-((i==0)?(cbSiceSecond-1)*2:0);
	    cbValidCount+=2;
			BYTE cbRemoveCount=__min(cbValidCount,cbTakeCount);
			if(i==1)
				cbRemoveCount=cbTakeCount;
	 		m_cbHeapCardInfo[wTakeChairID][(i==0)?1:0]+=cbRemoveCount;
      _sntprintf(szMsg, sizeof(szMsg), TEXT("%d 等待 %d 点数为 ..%d,%d"),wTakeChairID,cbSiceSecond,cbRemoveCount,cbTakeCount);

			//提取扑克
			cbTakeCount-=cbRemoveCount;

			//完成判断
			if (cbTakeCount==0)
			{
				m_wHeapHand=wTakeChairID;
				break;
			}

			//切换索引
			wTakeChairID=(wTakeChairID+1)%4;
      m_cbHeapCardInfo[wTakeChairID][(i==0)?1:0]+=cbTakeCount-1;
      break;
		}
		//////////////////////////////////////////////////////////////////////////
		m_wHeapHand = (m_wHeapTail+1)%4;
		m_cbHeapCardInfo[m_wHeapHand][0]=1;

		for (WORD i=0;i<4;i++)
		{
			//变量定义
			//WORD wViewChairID=(i+6-wMeChairID*2)%4;//SwitchViewChairID(i);
			WORD wViewChairID=SwitchHeapViewChairID(i);
			m_GameClientView.m_HeapCard[wViewChairID].SetCardData(m_cbHeapCardInfo[i][0],m_cbHeapCardInfo[i][1],HEAP_FULL_COUNT);
		}
		//////////////////////////////////////////////////////////////////////////
		BYTE byCardsIndex[MAX_INDEX]={0};
		ZeroMemory(byCardsIndex,sizeof(byCardsIndex));
		m_GameLogic.SwitchToCardIndex(pGamePlay->cbCardData[wMeChairID],(MAX_COUNT-1),byCardsIndex);

		BYTE byCards[MAX_COUNT]={0};
		ZeroMemory(byCards,sizeof(byCards));
		m_GameLogic.SwitchToCardData(byCardsIndex, byCards);

	//扑克设置
		for (WORD i=0;i<GAME_PLAYER;i++)
		{
			//变量定义
			WORD wViewChairID=SwitchViewChairID(i);

			//组合界面
			m_GameClientView.m_WeaveCard[i][0].SetDisplayItem(true);
			m_GameClientView.m_WeaveCard[i][1].SetDisplayItem(true);
			m_GameClientView.m_WeaveCard[i][2].SetDisplayItem(true);
			m_GameClientView.m_WeaveCard[i][3].SetDisplayItem(true);
			m_GameClientView.m_WeaveCard[i][4].SetDisplayItem(true);


			//用户扑克
			if (i!=wMeChairID)
			{
				WORD wIndex=(wViewChairID>=3)?2:wViewChairID;
				m_GameClientView.m_UserCard[wIndex].SetCardData(CountArray(pGamePlay->cbCardData[wMeChairID])-1,(i==m_wBankerUser));
			}
			else
			{
				BYTE cbBankerCard=(i==m_wBankerUser)?pGamePlay->cbCardData[wMeChairID][MAX_COUNT-1]:0;
				m_GameClientView.m_HandCardControl.SetCardData(byCards,MAX_COUNT-1,cbBankerCard);
			}

			//旁观界面
			if (bPlayerMode==false)
			{
				m_GameClientView.m_TableCard[wViewChairID].SetCardData(NULL,0);
				m_GameClientView.m_DiscardCard[wViewChairID].SetCardData(NULL,0);
				m_GameClientView.m_WeaveCard[wViewChairID][0].SetCardData(NULL,0);
				m_GameClientView.m_WeaveCard[wViewChairID][1].SetCardData(NULL,0);
				m_GameClientView.m_WeaveCard[wViewChairID][2].SetCardData(NULL,0);
				m_GameClientView.m_WeaveCard[wViewChairID][3].SetCardData(NULL,0);
				m_GameClientView.m_WeaveCard[wViewChairID][4].SetCardData(NULL,0);
			}
		}
		m_GameClientView.m_HandCardControl.SetOutCardData(NULL, 0);

		//更新界面
		m_GameClientView.SetCenterText(TEXT(""));

		SetGameStatus(GS_MJ_PLAY);
		//出牌提示
		if ((bPlayerMode==true)&&(m_wCurrentUser!=INVALID_CHAIR))
		{
			if (m_wCurrentUser==wMeChairID)
			{
				ActiveGameFrame();
				m_GameClientView.SetStatusFlag(true,false);
			}
		}
		m_GameClientView.m_HandCardControl.SetOutCardData(NULL, 0);
		m_GameClientView.m_HandCardControl.SetPositively(bPlayerMode);  // 现在才可以出牌

		//动作处理
		if ((bPlayerMode==true)&&(pGamePlay->cbUserAction!=WIK_NULL))
		{
			ShowOperateControl(pGamePlay->cbUserAction,0);
			SetGameClock(GetMeChairID(),IDI_OPERATE_CARD,TIME_OPERATE_CARD);
		}


		//设置时间
		if (m_wCurrentUser!=INVALID_CHAIR)
		{
			if ((m_wCurrentUser == wMeChairID) && (WIK_NULL==pGamePlay->cbUserAction))
			{
				m_GameClientView.m_HandCardControl.UpdateCardDisable(true);
			}
			m_GameClientView.SetCurrentUser(SwitchViewChairID(m_wCurrentUser));
			SetGameClock(m_wCurrentUser,IDI_OPERATE_CARD,TIME_OPERATE_CARD);
		}
	}
	return 0;
}
WORD CGameClientEngine::SwitchHeapViewChairID(WORD wChairID)
{
	// 转换椅子0位置为0， 1的位置为2
	WORD wViewChairID=(wChairID+4-GetMeChairID()*2);
	wViewChairID += 2;
	return wViewChairID%4;
}

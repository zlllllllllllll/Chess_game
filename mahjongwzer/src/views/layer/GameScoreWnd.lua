--
-- Author: zml
-- Date: 2017-12-8 15:48:39   可能不使用
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local CGameScoreWnd = class("CGameScoreWnd", function(scene)
	local CGameScoreWnd = display.newLayer()
	return CGameScoreWnd
end)

function CGameScoreWnd:ctor(scene)
	--设置变量
	self.m_GameScoreInfo={}
	self.m_GameScoreInfo.lScore={}
	self.m_GameScoreInfo.wCardType={}
	self.m_GameScoreInfo.szUserName=GameLogic:ergodicList(cmd.GAME_PLAYER)
	-- m_ImageBack.SetLoadInfo(IDB_GAME_SCORE,AfxGetInstanceHandle());
	--
	-- --移动窗口
	-- CImageHandle BackImageHandle(&m_ImageBack);
	-- SetWindowPos(NULL,0,0,m_ImageBack.GetWidth(),m_ImageBack.GetHeight(),SWP_NOZORDER|SWP_NOREPOSITION);

	return true

end

--重画函数
function CGameScoreWnd:OnPaint()
	-- CPaintDC dc(this);
	--
	-- --获取位置
	-- CRect rcClient;
	-- GetClientRect(&rcClient);
	--
	-- --创建缓冲
	-- CDC BufferDC;
	-- CBitmap ImageBuffer;
	-- BufferDC.CreateCompatibleDC(&dc);
	-- ImageBuffer.CreateCompatibleBitmap(&dc,rcClient.Width(),rcClient.Height());
	-- BufferDC.SelectObject(&ImageBuffer);
	--
	-- --绘画背景
	-- CImageHandle BackImageHandle(&m_ImageBack);
	-- m_ImageBack.BitBlt(BufferDC,0,0);
	--
	-- --设置 DC
	-- BufferDC.SetBkMode(TRANSPARENT);
	-- BufferDC.SetTextColor(RGB(230,230,230));
	-- BufferDC.SelectObject(CSkinAttribute::m_DefaultFont);
	--
	-- --绘画扑克
	-- g_CardResource.m_ImageUserBottom.DrawCardItem(&BufferDC,m_GameScoreInfo.cbChiHuCard,85,23);
	--
	-- --用户成绩
	-- CRect rcDraw;
	-- TCHAR szBuffer[64];
	-- for (int i=0;i<GAME_PLAYER;i++)
	-- {
	-- 	--用户名字
	-- 	rcDraw.left=25;
	-- 	rcDraw.right=125;
	-- 	rcDraw.top=125+i*25;
	-- 	rcDraw.bottom=rcDraw.top+12;
	-- 	BufferDC.DrawText(m_GameScoreInfo.szUserName[i],lstrlen(m_GameScoreInfo.szUserName[i]),&rcDraw,DT_CENTER|DT_VCENTER|DT_SINGLELINE|DT_END_ELLIPSIS);
	--
	-- 	--用户积分
	-- 	rcDraw.left=130;
	-- 	rcDraw.right=170;
	-- 	rcDraw.top=125+i*25;
	-- 	rcDraw.bottom=rcDraw.top+12;
	-- 	_snprintf(szBuffer,sizeof(szBuffer),TEXT("%ld"),m_GameScoreInfo.lScore[i]);
	-- 	BufferDC.DrawText(szBuffer,lstrlen(szBuffer),&rcDraw,DT_CENTER|DT_VCENTER|DT_SINGLELINE);
	--
	-- 	--用户状态
	-- 	if (m_GameScoreInfo.wCardType[i]!=0)
	-- 		BufferDC.TextOut(180,125+i*25,TEXT("胡牌"),4);
	-- 	else if (m_GameScoreInfo.wProvideUser==i)
	-- 		BufferDC.TextOut(180,125+i*25,TEXT("放炮"),4);
	--
	-- 	--其他信息
	-- 	if (m_GameScoreInfo.wBankerUser==i)
	-- 		BufferDC.TextOut(228,125+i*25,TEXT("是"),2);
	-- }
	--
	-- --游戏税收
	-- if(m_GameScoreInfo.lGameTax!=0L)
	-- {
	--
	-- 	rcDraw.left=25;
	-- 	rcDraw.right=125;
	-- 	rcDraw.top=125+4*25;
	-- 	rcDraw.bottom=rcDraw.top+12;
	-- 	LPCTSTR pszTax=TEXT("交易税");
	-- 	BufferDC.DrawText(pszTax,lstrlen(pszTax),&rcDraw,DT_VCENTER|DT_CENTER|DT_END_ELLIPSIS);
	--
	-- 	rcDraw.left=130;
	-- 	rcDraw.right=170;
	-- 	rcDraw.top=125+4*25;
	-- 	rcDraw.bottom=rcDraw.top+12;
	-- 	_snprintf(szBuffer,sizeof(szBuffer),TEXT("%ld"),m_GameScoreInfo.lGameTax);
	-- 	BufferDC.DrawText(szBuffer,lstrlen(szBuffer),&rcDraw,DT_CENTER|DT_VCENTER|DT_SINGLELINE);
	-- }
	--
	-- --绘制结果
	-- int row=0,colum=0;
	-- WORD  KindIndex[]={CHK_JI_HU,
	-- 	CHK_PING_HU,
	-- 	CHK_PENG_PENG,
	-- 	CHK_QI_XIAO_DUI,
	-- 	CHR_DI,
	-- 	CHR_TIAN,
	-- 	CHR_ZI_YI_SE,
	-- 	CHR_HUN_YI_SE,
	-- 	CHK_QING_YI_SE,
	-- 	CHR_QIANG_GANG,
	-- 	CHR_YI_TIAO_LONG,
	-- 	CHK_QUAN_QIU_REN,
	-- 	CHK_DA_SAN_YUAN};
	--
	-- TCHAR *KindBuffer[]={"鸡  胡","平  胡","碰碰胡","七小对","地  胡"," 天  胡",
	-- 	"字一色","混一色","清一色","杠  胡","一条龙","全求人","大三元"};
	--
	-- if(m_GameScoreInfo.wwChiHuKind!=0&&(m_GameScoreInfo.wwChiHuKind&0xff00)==0)
	-- {
	-- 	if(m_GameScoreInfo.wwChiHuKind!=0)
	-- 	{
	-- 		BufferDC.TextOut(28+colum*84,250+row*15,KindBuffer[1]);
	-- 		if(colum==2)
	-- 		{
	-- 			row++;
	-- 			colum=0;
	-- 		}
	-- 		else
	-- 			colum++;
	-- 	}
	-- }
	-- else
	-- {
	-- 	m_GameScoreInfo.wwChiHuKind&=0xff00;
	-- 	for(BYTE i=0;i<CountArray(KindIndex);i++)
	-- 	{
	-- 		if(i<4&&m_GameScoreInfo.wwChiHuKind&KindIndex[i])
	-- 		{
	-- 			BufferDC.TextOut(28+colum*84,250+row*15,KindBuffer[i]);
	-- 			if(colum==2)
	-- 			{
	-- 				row++;
	-- 				colum=0;
	-- 			}
	-- 			else
	-- 				colum++;
	-- 		}
	-- 		if(i>=4&&m_GameScoreInfo.wChiHuRight&KindIndex[i])
	-- 		{
	-- 			BufferDC.TextOut(28+colum*84,250+row*15,KindBuffer[i]);
	-- 			if(colum==2)
	-- 			{
	-- 				row++;
	-- 				colum=0;
	-- 			}
	-- 			else
	-- 				colum++;
	-- 		}
	-- 	}
	-- }
	--
	-- --绘画界面
	-- dc.BitBlt(0,0,rcClient.Width(),rcClient.Height(),&BufferDC,0,0,SRCCOPY);
	--
	-- --清理资源
	-- BufferDC.DeleteDC();
	-- ImageBuffer.DeleteObject();

	return
end

--绘画背景
function CGameScoreWnd:OnEraseBkgnd(pDC)
	-- Invalidate(FALSE);
	-- UpdateWindow();
	return true
end

--鼠标消息
function CGameScoreWnd:onResetData(nFlags,point)
	-- __super::OnLButtonDown(nFlags,point);
	--
	-- --消息模拟
	-- PostMessage(WM_NCLBUTTONDOWN,HTCAPTION,MAKELPARAM(point.x,point.y));

	return
end

--设置积分
function CGameScoreWnd:SetScoreInfo(GameScoreInfo)
	-- --设置变量
	-- m_GameScoreInfo=GameScoreInfo;
	--
	-- --显示窗口
	-- Invalidate(NULL);
	-- ShowWindow(SW_SHOW);

	return
end

function CGameScoreWnd:OnMove()
	-- __super::OnMove(x, y);
	--
	-- --刷新界面
	-- Invalidate(FALSE);
	-- UpdateWindow();

	return
end


return CGameScoreWnd

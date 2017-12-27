--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local bit =  appdf.req(appdf.BASE_SRC .. "app.models.bit")
local cmd = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.CMD_Game")
local GameLogic = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.models.GameLogic")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local ScoreControl = class("ScoreControl", function(scene)
	local ScoreControl = display.newLayer()
	return ScoreControl
end)

--按钮标识
ScoreControl.IDC_CLOSE_SCORE				=100									--关闭成绩

function ScoreControl:ctor()
	--设置变量
	self.m_cbWeaveCount=0
	self.m_ScoreInfo={}
	self.m_ScoreInfo.cbCardData={}
	self.m_ScoreInfo.szUserName=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_ScoreInfo.lGameScore={}
	self.m_ScoreInfo.lGodsScore={}
	self.m_ScoreInfo.byDingDi={}
	self.m_ScoreInfo.dwChiHuKind={}
	self.m_ScoreInfo.dwChiHuRight={}

	--加载资源
	--HINSTANCE hResInstance=AfxGetInstanceHandle();
	self.m_ImageWin=display.newSprite("res/game/SCORE_WIN.png"):setVisible(false):addTo(self)
	self.m_ImageDraw=display.newSprite("res/game/SCORE_DRAW.png"):setVisible(false):addTo(self)
	self.m_ImageGameScore=display.newSprite("res/game/GAME_SCORE.png"):setVisible(false):addTo(self)
	self.m_ImageGameScoreFlag=display.newSprite("res/game/GAME_SCORE_FLAG.png"):setVisible(false):addTo(self)

	--设置控件
	--CWeaveCard						m_WeaveCard[MAX_WEAVE];					//组合扑克
	self.m_WeaveCard={} 
	self.m_WeaveCard[1]=CardControl:create_CWeaveCard(self)
	self.m_WeaveCard[2]=CardControl:create_CWeaveCard(self)
	self.m_WeaveCard[3]=CardControl:create_CWeaveCard(self)
	self.m_WeaveCard[4]=CardControl:create_CWeaveCard(self)
	self.m_WeaveCard[5]=CardControl:create_CWeaveCard(self)

	--for (BYTE i=0;i<CountArray(m_WeaveCard);i++) m_WeaveCard[i].SetDirection(Direction_South);
	for i=1,cmd.MAX_WEAVE,1 do	self.m_WeaveCard[i]:SetDirection(CardControl.Direction_South) end

	--设置窗口
	--SetWindowPos(NULL,0,0,m_ImageGameScore.GetWidth(),m_ImageGameScore.GetHeight(),SWP_NOZORDER|SWP_NOMOVE);
	self:move(0,0)
	local bmp=display.newSprite("res/game/GAME_SCORE.png")
			:move(300,300)
			:setVisible(true)
			--:setColor(cc.c3b(255, 0, 255))
			:addTo(self)
	--self:BitmapToRegion(bmp,RGB(255, 0, 255))

	-- CBitmap bmp;
	-- if(bmp.LoadBitmap(IDB_GAME_SCORE))
	-- {
	-- 	HRGN rgn;
	-- 	rgn = BitmapToRegion((HBITMAP)bmp, RGB(255, 0, 255));
	-- 	--重绘区域
	-- 	SetWindowRgn(rgn, TRUE);
	-- 	bmp.DeleteObject();
	-- }

	local  btcallback = function(ref, type)
	  if type == ccui.TouchEventType.ended then
	   	self:OnBnClickedClose()
	  end
	end

	--创建按钮
	ccui.Button:create("res/game/BT_SCORE_CLOSE.png")
		:move(178,250)
		:setName("m_btCloseScore")
		:setTag(ScoreControl.IDC_CLOSE_SCORE)
		--:setEnabled(false)
		:addTo(self)
		:addTouchEventListener(btcallback)
	self.m_btCloseScore=self:getChildByName("m_btCloseScore")
	
	return 0
end

--复位数据
function ScoreControl:RestorationData()
	--设置变量
	self.m_cbWeaveCount=0
	self.m_ScoreInfo={}
	self.m_ScoreInfo.cbCardData={}
	self.m_ScoreInfo.szUserName=GameLogic:ergodicList(cmd.GAME_PLAYER)
	self.m_ScoreInfo.lGameScore={}
	self.m_ScoreInfo.lGodsScore={}
	self.m_ScoreInfo.byDingDi={}
	self.m_ScoreInfo.dwChiHuKind={}
	self.m_ScoreInfo.dwChiHuRight={}

	--隐藏窗口
	--if (m_hWnd!=NULL) ShowWindow(SW_HIDE);
	self:setVisible(false)

	return
end

--设置积分
function ScoreControl:SetScoreInfo(ScoreInfo,WeaveInfo,dwMeUserID)
	--设置变量
	self.m_ScoreInfo=ScoreInfo
	self.m_cbWeaveCount=WeaveInfo.cbWeaveCount
	self.m_dwMeUserID=dwMeUserID

	--组合变量
	for i=1,self.m_cbWeaveCount,1 do
		local bPublicWeave=(WeaveInfo.cbPublicWeave[i]==true)
		self.m_WeaveCard[i]:SetCardData(WeaveInfo.cbCardData[i],WeaveInfo.cbCardCount[i])
		self.m_WeaveCard[i]:SetDisplayItem(true)
	end

	--显示窗口
	self:setVisible(true)

	return
end

--关闭按钮
function ScoreControl:OnBnClickedClose()
	--隐藏窗口
	self:RestorationData()

	return
end

function ScoreControl:GetHardSoftHu()
	--牌型信息
	local dwCardKind={GameLogic.CHK_PENG_PENG,GameLogic.CHK_QI_XIAO_DUI,GameLogic.CHK_SHI_SAN_YAO,GameLogic.CHK_YING_PAI,GameLogic.CHK_SAN_GODS,GameLogic.CHK_BA_DUI,GameLogic.CHK_YING_BA_DUI}

	local iChiType=0
	while true do
	for i=1,cmd.GAME_PLAYER,1 do
		--用户过虑
		if self.m_ScoreInfo.dwChiHuKind[i]==GameLogic.CHK_NULL then
		else
			--牌型信息
			while true do
			for j=1,GameLogic:table_leng(dwCardKind),1 do
				if bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j]) then
					if GameLogic.CHK_BA_DUI == bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j]) and GameLogic.CHK_YING_BA_DUI == bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j+1]) then
						--continue;
					else
						iChiType=bit:_or(iChiType,dwCardKind[j])
						break
					end
				end
			end
			break end

			if iChiType==0 then
				if self.m_ScoreInfo.wProvideUser==(i-1) then
					iChiType=2
				else
					iChiType=1 --软胡
				end
			elseif bit:_and(iChiType , GameLogic.CHK_YING_PAI) then
					iChiType=2 	--硬胡
			elseif bit:_and(iChiType , GameLogic.CHK_YING_BA_DUI) or bit:_and(iChiType , GameLogic.CHK_SAN_GODS) then
					iChiType=3  --双翻
			else
				iChiType=0
				break
			end
		end
	end
	break end

	return iChiType
end

--重画函数
function ScoreControl:OnPaint()
	-- CPaintDC dc(this);

	--获取位置
	-- CRect rcClient;
	-- GetClientRect(&rcClient);
	--mark
	local rcClient={}
	rcClient.left=0
	rcClient.top=100
	rcClient.right=100
	rcClient.bottom=0
	rcClient.width=rcClient.right-rcClient.left
	rcClient.height=rcClient.top-rcClient.bottom

	--创建字体
	--CFont InfoFont;
	--InfoFont.CreatePointFont(110,TEXT("宋体"),&dc);
	--InfoFont.CreateFont(-16,0,0,0,FW_BOLD,0,0,0,134,3,2,1,2,TEXT("宋体"));

	--创建缓冲
	-- CDC DCBuffer;
	-- CBitmap ImageBuffer;
	-- DCBuffer.CreateCompatibleDC(&dc);
	-- ImageBuffer.CreateCompatibleBitmap(&dc,rcClient.Width(),rcClient.Height());

	--设置 DC
	-- DCBuffer.SetBkMode(TRANSPARENT);
	-- DCBuffer.SelectObject(&ImageBuffer);
	--设置 DC

	--加载资源
	--CImageHandle HandleWin(&m_ImageWin);
	--CImageHandle HandleDraw(&m_ImageDraw);
	--CImageHandle HandleGameScoreFlag(&m_ImageGameScoreFlag);

	--绘画背景
	--self.m_ImageGameScore.Draw(DCBuffer.GetSafeHdc(),0,0);
	--self.m_ImageGameScore=GameLogic:FillSolidRect(0, 0, rcClient.width, rcClient.height, cc.c4f(255,255,255,0))
	self.m_ImageGameScore:move(0,0)
				:setVisible(true)
	--绘画扑克
	if self.m_ScoreInfo.lGameScore[self.m_dwMeUserID]<0 then
		--位置变量
		local nCardSpace=2
		local nItemWidth=CardControl.CCardList["m_ImageTableBottom"].m_nViewWidth
		local nTotalWidth=self.m_cbWeaveCount*(nItemWidth*3+nCardSpace)+nItemWidth*self.m_ScoreInfo.cbCardCount+nCardSpace

		--计算位置
		local nYCardPos=79
		local nXCardPos=(self.m_ImageGameScore:getContentSize().width-nTotalWidth)/2

		--绘画组合
		for i=1,self.m_cbWeaveCount,1 do
			--绘画扑克
			self.m_WeaveCard[i]:DrawCardControl(nil,nXCardPos,nYCardPos)

			--设置位置
			nXCardPos=nXCardPos+(nCardSpace+nItemWidth*3)
		end

		nXCardPos =nXCardPos+ 3
		for i=1,self.m_ScoreInfo.cbCardCount,1 do
			--绘画扑克
			local nXCurrentPos=nXCardPos
			local nYCurrentPos=nYCardPos-CardControl.CCardList["m_ImageTableBottom"].m_nViewHeight-5
			self.g_CardResource=CardControl:create_CCardListImage(self)
			self.g_CardResource:DrawCardItem("m_ImageTableBottom",nil,self.m_ScoreInfo.cbCardData[i],nXCurrentPos,nYCurrentPos)

			--设置位置
			nXCardPos=nXCardPos+nItemWidth
			if (i+2-1)==self.m_ScoreInfo.cbCardCount then
				nXCardPos=nXCardPos+nCardSpace + 3
			end
		end
	end

	--绘画牌型
	while true do
	for i=1,cmd.GAME_PLAYER,1 do
		--用户过虑
		if self.m_ScoreInfo.dwChiHuKind[i]==GameLogic.CHK_NULL then
			-- continue;
		else
			--牌型信息
			local dwCardKind={GameLogic.CHK_PENG_PENG,GameLogic.CHK_QI_XIAO_DUI,GameLogic.CHK_SHI_SAN_YAO,GameLogic.CHK_YING_PAI,GameLogic.CHK_SAN_GODS,GameLogic.CHK_BA_DUI,GameLogic.CHK_YING_BA_DUI}
			local dwCardRight={GameLogic.CHR_DI,GameLogic.CHR_TIAN,GameLogic.CHR_QING_YI_SE,GameLogic.CHR_QIANG_GANG,GameLogic.CHK_QUAN_QIU_REN}

			--牌型信息
			local strCardInfo=""
			local pszCardKind={"碰碰胡","七小对","十三幺","硬胡","三财神","八对","硬八对"}
			local pszCardRight={"地胡","天胡","清一色","杠胡","全求人"}

			--牌型信息
			while true do
			for j=1,GameLogic:table_leng(dwCardKind),1 do
				if bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j]) then
					if GameLogic.CHK_BA_DUI == bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j]) and GameLogic.CHK_YING_BA_DUI == bit:_and(self.m_ScoreInfo.dwChiHuKind[i],dwCardKind[j+1]) then
						--continue;
					else
						strCardInfo=pszCardKind[j]
						break
					end
				end
			end
			break end
			--if strCardInfo.IsEmpty() then  IsEmpty 判断未初始化 问题是已经初始化
			--if strCardInfo==nil then
			if strCardInfo== "" or strCardInfo == nil then
				if self.m_ScoreInfo.wProvideUser==i then
					strCardInfo = "硬胡"
				else
					strCardInfo = "软胡"
				end
			end
			-- CRect rcCardKind(125,100,175,116);--修改175-375
			-- DCBuffer.DrawText(strCardInfo,rcCardKind,DT_SINGLELINE|DT_END_ELLIPSIS|DT_VCENTER);
			cc.Label:createWithTTF(strCardInfo,"fonts/round_body.ttf", 24)
				:move((125+175)/2,(100+116)/2)
				:setTextColor(cc.c4b(0,0,0,255))
			--牌权信息
			strCardInfo=""
			while true do
			for j=1,GameLogic:table_leng(dwCardRight),1 do
				if bit:_and(self.m_ScoreInfo.dwChiHuRight[i],dwCardRight[j]) then
					if GameLogic.CHR_QIANG_GANG == bit:_and(self.m_ScoreInfo.dwChiHuRight[i],dwCardRight[j]) then
						--continue
					else
						strCardInfo=pszCardRight[j]
						break
					end
				end
			end
			break end
			if strCardInfo== "" or strCardInfo == nil then
				strCardInfo = "普通"
			end

			--绘画信息
			-- CRect rcCardInfo(355,100,405,116);
			-- DCBuffer.DrawText(strCardInfo,rcCardInfo,DT_SINGLELINE|DT_END_ELLIPSIS);
			cc.Label:createWithTTF(strCardInfo,"fonts/round_body.ttf", 24)
				:move((355+405)/2,(100+116)/2)
				:setTextColor(cc.c4b(0,0,0,255))

			break
		end
	end
	break end


	--积分信息
	for i=1,cmd.GAME_PLAYER,1 do
		--变量定义
		local szUserScore=""
		szUserScore=self.m_ScoreInfo.lGameScore[i]
		--_sntprintf(szUserScore,CountArray(szUserScore),TEXT("%I64d"),m_ScoreInfo.lGameScore[i]);

		--位置计算
		local rcName={}
		rcName.left=135+i*140	rcName.top=123	rcName.right=135+140+i*140	rcName.bottom=160
		rcName.width=rcName.right-rcName.left 	rcName.height=rcName.top-rcName.bottom

		local rcDingDi={}
		rcDingDi.left=123	rcDingDi.top=165+i*30	rcDingDi.right=158	rcDingDi.bottom=165+(i+1)*30
		rcDingDi.width=rcDingDi.right-rcDingDi.left		rcDingDi.height=rcDingDi.top-rcDingDi.bottom
		local rcGods={}
		rcGods.left=181	rcGods.top=165+i*30	rcGods.right=236	rcGods.bottom=165+(i+1)*30
		rcGods.width=rcGods.right-rcGods.left		rcGods.height=rcGods.top-rcGods.bottom
		local rcScore={}
		rcScore.left=160	rcScore.top=215	rcScore.right=320	rcScore.bottom=230
		rcScore.width=rcScore.right-rcScore.left		rcScore.height=rcScore.top-rcScore.bottom
		local rcStatus={}
		rcStatus.left=323	rcStatus.top=165+i*30	rcStatus.right=363	rcStatus.bottom=165+(i+1)*30
		rcStatus.width=rcStatus.right-rcStatus.left		rcStatus.height=rcStatus.top-rcStatus.bottom

		--绘画信息
		--local nFormat=DT_SINGLELINE|DT_END_ELLIPSIS|DT_VCENTER;

		if self.m_dwMeUserID==(i-1) then
			--DCBuffer.DrawText(szUserScore,lstrlen(szUserScore),&rcScore,nFormat);
			cc.Label:createWithTTF(szUserScore,"fonts/round_body.ttf", 24)
				:move((355+405)/2,(100+116)/2)
				:setTextColor(cc.c4b(0,0,0,255))
			if self.m_ScoreInfo.lGameScore[i]>0 then	--胜
				self.m_ImageWin:setPosition(90,14)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
			if self.m_ScoreInfo.lGameScore[i]<0 then--负
				local strInfo="玩家："..self.m_ScoreInfo.szUserName[1-i].." 胡了！"
				--CRect rcInfo(7,9,443,29);
				cc.Label:createWithTTF(strInfo,"fonts/round_body.ttf", 24)
					:move((7+443)/2,(9+29)/2)
					:setTextColor(cc.c4b(255,255,58,255))
			end
			if self.m_ScoreInfo.lGameScore[i]==0 then--流局
				self.m_ImageDraw:setPosition(102,7)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
		end

		cc.Label:createWithTTF(self.m_ScoreInfo.szUserName[i],"fonts/round_body.ttf", 24)
			:move((rcName.left+rcName.right)/2,(rcName.bottom+rcName.top)/2)
			:setTextColor(cc.c4b(0,0,0,255))

		--庄家标志
		if self.m_ScoreInfo.wBankerUser==i then
			if self.m_ScoreInfo.byDingDi[i]>0 then		--买底
				self.m_ImageGameScoreFlag:setPosition(195+i*140,155)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
		else
			if self.m_ScoreInfo.byDingDi[i]>0 then		--顶底
				self.m_ImageGameScoreFlag:setPosition(195+i*140,185)
					:setColor(cc.c3b(255, 0, 255))
					:setVisible(true)
			end
		end
	end
	--胜、负、流局

	--绘画界面
	--dc.BitBlt(0,0,rcClient.Width(),rcClient.Height(),&DCBuffer,0,0,SRCCOPY);
	--清理资源
	return
end

--绘画背景
function ScoreControl:OnEraseBkgnd(pDC)
	--更新界面
	--Invalidate(FALSE);
	--UpdateWindow()

	return true
end

--鼠标消息
function ScoreControl:OnLButtonDown(nFlags,Point)
	--__super::OnLButtonDown(nFlags,Point);

	--消息模拟
	--PostMessage(WM_NCLBUTTONDOWN,HTCAPTION,MAKELPARAM(Point.x,Point.y));

	return
end

function ScoreControl:OnMove(x,y)
	-- __super::OnMove(x, y);
	--
	-- --更新界面
	-- Invalidate(FALSE);
	-- UpdateWindow();
end

--HRGN CScoreControl::BitmapToRegion(HBITMAP hBmp, COLORREF cTransparentColor, COLORREF cTolerance)
function ScoreControl:BitmapToRegion(hBmp, cTransparentColor, cTolerance)
		--
		-- mark
		-- 
end

return ScoreControl

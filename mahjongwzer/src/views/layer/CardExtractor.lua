--
-- Author: zml
-- Date: 2017-12-8 15:48:39
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local GameLayer = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.GameLayer")
local CardControl = appdf.req(appdf.GAME_SRC.."yule.mahjongwzer.src.views.layer.CardControl")
local CardExtractor = class("CardExtractor", function(scene)
	local CardExtractor = display.newLayer()
	return CardExtractor
end)

function CardExtractor:ctor(scene)
	self._scene = scene
	local this = self

	self.m_pClientDlg = nil
	self.m_CardCtrl[0]=CardControl:create_CCardControl(self)
	self.m_CardCtrl[1]=CardControl:create_CCardControl(self)
	self.m_CardCtrl[2]=CardControl:create_CCardControl(self)
	self.m_CardCtrl[3]=CardControl:create_CCardControl(self)

	self.m_CardCtrl[0]:SetCardData(nil,0,0)
	self.m_CardCtrl[0]:SetPositively(true)
	self.m_CardCtrl[0]:SetDisplayItem(true)

	self.m_CardCtrl[1]:SetCardData(nil,0,0)
	self.m_CardCtrl[1]:SetPositively(true)
	self.m_CardCtrl[1]:SetDisplayItem(true)

	self.m_CardCtrl[2]:SetCardData(nil,0,0)
	self.m_CardCtrl[2]:SetPositively(true)
	self.m_CardCtrl[2]:SetDisplayItem(true)

	self.m_CardCtrl[3]:SetCardData(nil,0,0)
	self.m_CardCtrl[3]:SetPositively(true)
	self.m_CardCtrl[3]:SetDisplayItem(true)

	self.m_cbHoverCard=0
end


function CardExtractor:DoDataExchange(pDX)
	--CDialog::DoDataExchange(pDX);
	print("!!! CDialog::DoDataExchange(pDX);")
end

function CardExtractor:OnPaint()
	--CPaintDC dc(this);
	-- device context for painting
	-- TODO: 在此处添加消息处理程序代码
	-- 不为绘图消息调用 CDialog::OnPaint()

	--self.m_CardCtrl[0].DrawCardControl(&dc)
	self.m_CardCtrl[0]:DrawCardControl()
	self.m_CardCtrl[1]:DrawCardControl()
	self.m_CardCtrl[2]:DrawCardControl()
	self.m_CardCtrl[3]:DrawCardControl()

	if self.m_cbHoverCard~=0 then
		self.g_CardResource=CardControl:create_CCardListImage(self)
		self.g_CardResource:DrawCardItem("m_ImageUserBottom",nil,self.m_cbHoverCard,30,50)
	end

end

function CardExtractor:OnInitDialog()
	--CDialog::OnInitDialog();

	-- TODO:  在此添加额外的初始化
	local nWidth = yl.WIDTH
	local nHeight = 100

	self.m_CardCtrl[0]:SetBenchmarkPos(nWidth/2-80,nHeight + 5,CardControl.enXCenter,CardControl.enYBottom)
	self.m_CardCtrl[1]:SetBenchmarkPos(nWidth/2-80,nHeight + 105,CardControl.enXCenter,CardControl.enYBottom)
	self.m_CardCtrl[2]:SetBenchmarkPos(nWidth/2-80,nHeight + 205,CardControl.enXCenter,CardControl.enYBottom)
	self.m_CardCtrl[3]:SetBenchmarkPos(nWidth/2-80,nHeight + 305,CardControl.enXCenter,CardControl.enYBottom)

	local byCardData={{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09},						--万子
	{ 0x11, 0x12 , 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19},															--索子
	{ 0x21 ,0x22 ,0x23 ,0x24 ,0x25 ,0x26 ,0x27 ,0x28 ,0x29},															--同子
	{ 0x31 ,0x32 ,0x33 ,0x34 ,0x35 ,0x36 ,0x37}																						--番子
	}
	self.m_CardCtrl[0]:SetCardData(byCardData[0], 9, 0)
	self.m_CardCtrl[1]:SetCardData(byCardData[1], 9, 0)
	self.m_CardCtrl[2]:SetCardData(byCardData[2], 9, 0)
	self.m_CardCtrl[3]:SetCardData(byCardData[3], 7, 0)

	return TRUE;
	-- return TRUE unless you set the focus to a control
	-- 异常: OCX 属性页应返回 FALSE
end

function CardExtractor:OnLButtonDown( nFlags, point)
	-- TODO: 在此添加消息处理程序代码和/或调用默认值

	--CDialog::OnLButtonDown(nFlags, point);
	while true do
		for i=0,4-1,1 do
			--获取扑克
			local cbHoverCard=self.m_CardCtrl[i]:GetHoverCard()
			if cbHoverCard~=0 then
				if cbHoverCard~=0 then
					self.m_cbHoverCard=cbHoverCard
					--Invalidate(FALSE) 窗口无效
				break	end
			end
		end
	break end
end

function CardExtractor:OnOK()
	--if self.m_cbHoverCard~=0 and nil ~= self.m_pClientDlg then
	if self.m_cbHoverCard~=0 then
		GameLayer(cmd.SUB_C_SET_CARD, self.m_cbHoverCard)
	end
	--获取变量
	--__super::OnOK() --关闭对话框
end

function CardExtractor:OnSetCursor(pWnd, nHitTest, message)
	--获取光标
	CPoint MousePoint;
	GetCursorPos(&MousePoint);
	ScreenToClient(&MousePoint);
	--获取点击坐标~！！！！！

	--点击测试
	local bRePaint=false
	local bHandle= false
	while true do
	for i=1,4-1,1 do
		bHandle = self.m_CardCtrl[i]:OnEventSetCursor(MousePoint,bRePaint)
		if bHandle or bHandle==0 then	break	end
	break end
	end

	--光标控制
	-- if (bHandle==false)
	-- 	__super::OnSetCursor(pWnd,nHitTest,message);
	return true
end


--------------------------------------------------------------

return CardExtractor

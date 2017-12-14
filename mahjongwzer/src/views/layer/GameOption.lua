--
-- Author: zml
-- Date: 2017-12-8 15:48:39   可能不需要使用
--
local cmd = appdf.req(appdf.GAME_SRC.."yule.sparrowhz.src.models.CMD_Game")
local CGameOption = class("CGameOption", function(scene)
	local CGameOption = display.newLayer()
	return CGameOption
end)

--象素定义
CGameOption.MAX_PELS					= 25									--最小象素
CGameOption.LESS_PELS					= 10									--最小象素
CGameOption.DEFAULT_PELS			=	18									--默认象素

function CGameOption:ctor()
	self.m_bEnableSound=true
	self.m_dwCardHSpace=CGameOption.DEFAULT_PELS
	return
end

--控件绑定
function CGameOption:DoDataExchange(pDX)
	--__super::DoDataExchange(pDX);
	--mark
	DDX_Control(pDX, IDOK, m_btOK);
	DDX_Control(pDX, IDCANCEL, m_btCancel);
end

--初始化函数
function CGameOption:OnInitDialog()
	--__super::OnInitDialog();

	--设置标题
	--SetWindowText(TEXT("游戏配置"));

	--调整参数
	if (self.m_dwCardHSpace>CGameOption.MAX_PELS) or (self.m_dwCardHSpace<CGameOption.LESS_PELS) then
		 self.m_dwCardHSpace=CGameOption.DEFAULT_PELS
	end

	--设置控件
	if self.m_bEnableSound==true then
		--mark 下同
		GetDlgItem(IDC_ENABLE_SOUND):SetCheck(BST_CHECKED);
	end

	return true
end

--确定消息
function CGameOption:OnOK()
	--获取变量
	self.m_bEnableSound=(GetDlgItem(IDC_ENABLE_SOUND):GetCheck()==BST_CHECKED);

	-- if ((!m_bHaveVoiceCard)&&m_bEnableSound)
	-- {
	-- 	--AfxMessageBox(_T("无法找到声音设备!"));
	-- }

	-- __super::OnOK();
end


--------------------------------------------------------------

return CGameOption

EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX = 6;  -- ���յ���ɫ�������������ֵ
EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX = 3;  -- ���յ���ɫ�������������ֵ
EV_UI_SELECT_CHAR_FREEZE_STATE_KEY = "RoleFreezeState"; -- ����״̬�ֶ�
function laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_OnEvent_ReceiveRoleInfoList(self)
	local btOk = SAPI.GetChild(self, "btOk");
	local btReturn = SAPI.GetChild(self, "btReturn");
	btOk:Enable();
	local RoleCount = uiCharGetRoleCount(false);	-- ��ǰ��ɫ����
	local ActiveRoleCount = 0;				-- �Ѽ����ɫ���� (����ͳ��)
	local FreezeCount = 0;					-- �Ѷ����ɫ���� (����ͳ��)
	if RoleCount > EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX then
		uiError("LUA_ERROR: RoleCount > "..EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX.." error!!!!!!!!!!!");
		RoleCount = EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX;
	end
	for i = 0,RoleCount-1,1 do
		local name, level, party, lockedTimeLeft, _, freeze, deletetime = uiCharGetRoleInfo(i, false);
		local role_widget = SAPI.GetChild(self, "wtRole"..i);
		local lbName = SAPI.GetChild(role_widget, "lbName");
		local lbParty = SAPI.GetChild(role_widget, "lbParty");
		local lbLevel = SAPI.GetChild(role_widget, "lbLevel");
		local cbFreeze = SAPI.GetChild(role_widget, "cbFreeze");
		local cbDelete = SAPI.GetChild(role_widget, "cbDelete");
		local ebAutoDeleteTip = SAPI.GetChild(role_widget, "ebAutoDeleteTip");
		if freeze == false then
			--lbName:SetTextColorEx(0, 255, 255, 255);
			--lbParty:SetTextColorEx(255, 255, 255, 255);
			--lbLevel:SetTextColorEx(255, 255, 255, 255);
			--cbFreeze:SetText(LAN("msg_role_active_op_freeze"));
			cbFreeze:SetChecked(false);
			ebAutoDeleteTip:SetText("");
			ActiveRoleCount = ActiveRoleCount + 1;
			role_widget:Set(EV_UI_SELECT_CHAR_FREEZE_STATE_KEY, false);
		else
			--lbName:SetTextColorEx(155, 155, 155, 255);
			--lbParty:SetTextColorEx(155, 155, 155, 255);
			--lbLevel:SetTextColorEx(155, 155, 155, 255);
			--cbFreeze:SetText(LAN("msg_role_active_op_active"));
			cbFreeze:SetChecked(true);
			ebAutoDeleteTip:SetTextColorEx(0, 0, 255, 255);
			local year, month, day, hour, minute, second = uiBank_TimeGetDate(deletetime);
			ebAutoDeleteTip:SetText(string.format(LAN("msg_role_active_op_auto_delete_date"), year, month, day));
			FreezeCount = FreezeCount + 1;
			role_widget:Set(EV_UI_SELECT_CHAR_FREEZE_STATE_KEY, true);
		end
		--cbFreeze:Enable(true);
		--cbDelete:Enable(true);
		--cbDelete:SetText(LAN("msg_role_active_op_delete"));
		cbDelete:SetChecked(false);
		lbName:SetText(name);
		lbParty:SetText(uiGetPartyInfo(party));
		lbLevel:SetText(LAN("msg_level")..level);
		role_widget:Show();
		laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_API_RoleStateChanged(role_widget);
	end
	for i = RoleCount,EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX-1,1 do
		SAPI.GetChild(self, "wtRole"..i):Hide();				-- �Ѳ���Ҫ�����ص�
	end
	if ActiveRoleCount > EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX or (ActiveRoleCount < EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX and FreezeCount > 0) then
		self:ShowModal();
	else
		self:Hide();
	end
	btReturn:SetText(LAN("msg_role_active_op_return"));
	local btRoleActive = uiGetglobal("laySelectChar.btRoleActive");
	if FreezeCount > 0 then
		btRoleActive:Show();
	else
		btRoleActive:Hide();
	end
	laySelectChar_RefreshRoleActiveButton();
end

function laySelectChar_RefreshRoleActiveButton()
	local RoleCount = uiCharGetRoleCount(false);	-- ��ǰ��ɫ����
	local btOk = uiGetglobal("laySelectChar.wtLayerRoleActiveGlobal.fmRoleActive.btOk");
	local form = uiGetglobal("laySelectChar.wtLayerRoleActiveGlobal.fmRoleActive");
	local ActiveCount = 0;
	local FreezeCount = 0;
	local DeleteCount = 0;
	for i = 0,RoleCount-1,1 do
		local role_widget = SAPI.GetChild(form, "wtRole"..i);
		if role_widget:getVisible() == true then
			local cbFreeze = SAPI.GetChild(role_widget, "cbFreeze");
			local cbDelete = SAPI.GetChild(role_widget, "cbDelete");
			if cbDelete:getChecked() == true then
				DeleteCount = DeleteCount + 1;
			elseif cbFreeze:getChecked() == true then
				FreezeCount = FreezeCount + 1;
			else
				ActiveCount = ActiveCount + 1;
			end
		end
	end
	if ActiveCount > EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX then
		btOk:Disable();
		btOk:SetText(LAN("msg_role_active_op_error_1"));
	elseif ActiveCount < EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX and FreezeCount > 0 then
		btOk:Disable();
		btOk:SetText(LAN("msg_role_active_op_error_2"));
	else
		btOk:Enable();
		btOk:SetText(LAN("msg_role_active_op_ok"));
	end
end

-- ģ��
function TemplateSelectCharActiveRoleBar_cbFreeze_OnLClick(self)
	laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_API_RoleStateChanged(SAPI.GetParent(self));
	--[[
	local lbName = SAPI.GetSibling(self, "lbName");
	local lbParty = SAPI.GetSibling(self, "lbParty");
	local lbLevel = SAPI.GetSibling(self, "lbLevel");
	if self:getChecked() == true then
		lbName:SetTextColorEx(155, 155, 155, 255);
		lbParty:SetTextColorEx(155, 155, 155, 255);
		lbLevel:SetTextColorEx(155, 155, 155, 255);
		self:SetText(LAN("msg_role_active_op_active"));
	else
		lbName:SetTextColorEx(0, 255, 255, 255);
		lbParty:SetTextColorEx(255, 255, 255, 255);
		lbLevel:SetTextColorEx(255, 255, 255, 255);
		self:SetText(LAN("msg_role_active_op_freeze"));
	end
	]]
	laySelectChar_RefreshRoleActiveButton();
end

function TemplateSelectCharActiveRoleBar_cbDelete_OnLClick(self)
	laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_API_RoleStateChanged(SAPI.GetParent(self));
	--[[
	local lbName = SAPI.GetSibling(self, "lbName");
	local lbParty = SAPI.GetSibling(self, "lbParty");
	local lbLevel = SAPI.GetSibling(self, "lbLevel");
	local cbFreeze = SAPI.GetSibling(self, "cbFreeze");
	-- ��ť״̬
	if self:getChecked() == true then
		self:SetText(LAN("msg_role_active_op_undelete"));
		cbFreeze:Disable();
	else
		self:SetText(LAN("msg_role_active_op_delete"));
		cbFreeze:Enable();
	end
	-- ������ɫ
	if self:getChecked() == true or cbFreeze:getChecked() == true then
		lbName:SetTextColorEx(155, 155, 155, 255);
		lbParty:SetTextColorEx(155, 155, 155, 255);
		lbLevel:SetTextColorEx(155, 155, 155, 255);
	else
		lbName:SetTextColorEx(0, 255, 255, 255);
		lbParty:SetTextColorEx(255, 255, 255, 255);
		lbLevel:SetTextColorEx(255, 255, 255, 255);
	end
	]]
	laySelectChar_RefreshRoleActiveButton();
end

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_btOk_OnLClick(self)
	local RoleCount = uiCharGetRoleCount(false);	-- ��ǰ��ɫ����
	local form = SAPI.GetParent(self);
	local bOperationOn = false;
	local ActiveCount = 0;
	local FreezeCount = 0;
	local DeleteCount = 0;
	for i = 0,RoleCount-1,1 do
		local role_widget = SAPI.GetChild(form, "wtRole"..i);
		if role_widget:getVisible() == true then
			local oldFreezeState = role_widget:Get(EV_UI_SELECT_CHAR_FREEZE_STATE_KEY);
			local cbFreeze = SAPI.GetChild(role_widget, "cbFreeze");
			local cbDelete = SAPI.GetChild(role_widget, "cbDelete");
			local bFreeze = cbFreeze:getChecked();
			local bDelete = cbDelete:getChecked();
			if bFreeze ~= oldFreezeState then -- ����״̬�ı�
				uiCharSetRoleFreezeState(i, bFreeze); -- ���ü���״̬
				bOperationOn = true;
			end
			if bDelete == true then -- ɾ��
				uiCharSetRoleDeleteState(i, bDelete); -- ����ɾ��״̬
				bOperationOn = true;
				DeleteCount = DeleteCount + 1;
			elseif bFreeze == true then
				FreezeCount = FreezeCount + 1;
			else
				ActiveCount = ActiveCount + 1;
			end
		end
	end
	-- �ٴμ�� �Ƿ���Ҳ����Ƿ���Ч
	if ActiveCount > EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX or (ActiveCount < EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX and FreezeCount > 0) then
		return;
	end
	-- �ύ����
	if bOperationOn == true then
		laySelectChar_RefreshRoleActiveButton(); -- �ٴμ��
		uiCharSendActiveRoleOperator();
	else
		SAPI.GetParent(self):Hide();
	end
end

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_btReturn_OnLClick(self)
	--[[
	local RoleCount = uiCharGetRoleCount(false);	-- ��ǰ��ɫ����
	local ActiveRoleCount = 0;				-- �Ѽ����ɫ���� (����ͳ��)
	if RoleCount > EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX then
		RoleCount = EV_UI_SELECT_CHAR_RECEIVE_ROLE_MAX;
	end
	for i = 0,RoleCount-1,1 do
		local name, level, party, lockedTimeLeft, _, freeze, deletetime = uiCharGetRoleInfo(i, false);
		if freeze == false then
			ActiveRoleCount = ActiveRoleCount + 1;
		end
	end
	SAPI.GetParent(self):Hide(); -- �ر�
	if ActiveRoleCount > EV_UI_SELECT_CHAR_ACTIVE_ROLE_MAX then
		uiCharStageReturn(); -- ����
	end
	]]
	SAPI.GetParent(self):Hide();
	uiCharStageReturn(); -- ���ص���¼����
end

------------------------------------------------------------------------------------------------
-- laySelectChar.wtLayerRoleActiveGlobal.fmRoleRename �ڶ���form (����������)
------------------------------------------------------------------------------------------------
function laySelectChar_wtLayerRoleActiveGlobal_fmRoleRename_btOk_OnLClick(self)
	local ebNewName = SAPI.GetSibling(self, "ebNewName");
	local newName = ebNewName:getText();
	local newNameLength = string.len(newName);
	if newNameLength < 3 or newNameLength > 16 then -- �����ֵĳ��ȼ��
		local ebErrorMsg = SAPI.GetSibling(self, "ebErrorMsg");
		ebErrorMsg:SetTextColorEx(0, 0, 255, 255)-- ��ʾ��ɫ
		ebErrorMsg:SetText(LAN("msg_login7"))-- ��ʾ�ı�
		return;
	end
	uiCharRename(newName);
	if uiCharEnterGame() == true then
		SAPI.GetParent(self):Hide();
	end
end

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleRename_btCancel_OnLClick(self)
	SAPI.GetParent(self):Hide();
end

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleRename_OnEvent_SelectCharRenameRequest(self)
	local select = uiCharGetCurrentRoleIndex();
	if select ~= nil and select ~= -1 then
		local name, level, party, lockedTimeLeft, needRename, freeze, deletetime = uiCharGetRoleInfo(select, true);
		if needRename == true then
			self:ShowModal();
		else
			self:Hide();
			uiCharEnterGame();
		end
	else
		uiError("none selection!!!!!!");	-- û��ѡ���ɫ,�����κβ���
	end
end

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleRename_OnEvent_SelectCharRenameResult(self, args)
	local result = args[1];
	local errorMsg = "";
	if result == 1 then -- ����
		errorMsg = LAN("msg_login5");
	elseif result == 3 then -- ���ֳ��ȴ���
		errorMsg = LAN("msg_login7");
	elseif result == 4 then -- ����ֻ�ܰ���ָ���ַ�����Сд��ĸ�����ֺͺ��֣�
		errorMsg = LAN("msg_login12");
	elseif result == 5 then -- �����ַ�����
		errorMsg = LAN("msg_login11");
	elseif result == 0 then -- ��������
		errorMsg = args[2];
		uiMessageBox(errorMsg, "", true, false, true);
		return;
	end
	local ebErrorMsg = SAPI.GetChild(self, "ebErrorMsg");
	ebErrorMsg:SetTextColorEx(0, 0, 255, 255)-- ��ʾ��ɫ
	ebErrorMsg:SetText(errorMsg)-- ��ʾ�ı�
	self:ShowModal();
end

-- API

function laySelectChar_wtLayerRoleActiveGlobal_fmRoleActive_API_RoleStateChanged(wtRole)
	local lbName = SAPI.GetChild(wtRole, "lbName");
	local lbParty = SAPI.GetChild(wtRole, "lbParty");
	local lbLevel = SAPI.GetChild(wtRole, "lbLevel");
	local cbFreeze = SAPI.GetChild(wtRole, "cbFreeze");
	local cbDelete = SAPI.GetChild(wtRole, "cbDelete");
	local bFreeze = cbFreeze:getChecked();
	local bDelete = cbDelete:getChecked();
	cbFreeze:Enable();
	cbDelete:Enable();
	
	-- ���þ�̬������ɫ
	if bFreeze == true or bDelete == true then
		lbName:SetTextColorEx(155, 155, 155, 255);
		lbParty:SetTextColorEx(155, 155, 155, 255);
		lbLevel:SetTextColorEx(155, 155, 155, 255);
		if bDelete == true then
			cbFreeze:Disable();
		end
	else
		lbName:SetTextColorEx(0, 255, 255, 255);
		lbParty:SetTextColorEx(255, 255, 255, 255);
		lbLevel:SetTextColorEx(255, 255, 255, 255);
	end
	
	-- ���ð�ť����
	if bFreeze == true then
		cbFreeze:SetText(LAN("msg_role_active_op_active"));
	else
		cbFreeze:SetText(LAN("msg_role_active_op_freeze"));
	end
	if bDelete == true then
		cbDelete:SetText(LAN("msg_role_active_op_undelete"));
	else
		cbDelete:SetText(LAN("msg_role_active_op_delete"));
	end
end








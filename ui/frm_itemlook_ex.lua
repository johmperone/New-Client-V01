
-- ˢ��ָ��װ��
function TemplateBtnOtherEquip_Refresh(self)
	local part = self:Get(EV_UI_EQUIP_PART_KEY);
	local id, classid = uiSeeEquipGetCurEquipItemByPart(part); -- ��ȡ�˲�λ�ĵ�ǰװ��
	if id == nil or id == 0 or classid == nil or classid == 0 then
		self:Delete(EV_UI_SHORTCUT_OBJECTID_KEY);
		self:Delete(EV_UI_SHORTCUT_CLASSID_KEY);
		self:SetNormalImage(0); -- ���ͼ��
	else
		self:Set(EV_UI_SHORTCUT_OBJECTID_KEY, id);
		self:Set(EV_UI_SHORTCUT_CLASSID_KEY, classid);
		local tableInfo = uiItemGetItemClassInfoByTableIndex(classid); -- ���ߵľ�̬��Ϣ
		self:SetNormalImage(SAPI.GetImage(tableInfo.Icon)); -- ����ͼ��
	end
end
function layWorld_frmItemlookEx_modelOther_RefreshPart(self, part)
	uiInfo("layWorld_frmItemlookEx_modelOther_RefreshPart[ "..tostring(part).." ]")
	local model_pre = "SELF_SUB_MODEL";
	local path_pre = "SELF_SUB_PATH";
	if self == nil then self = uiGetglobal("layWorld.frmItemlookEx.modelOther") end
	local model= uiSeeEquipGetCurEquipModelByPart(part);
	local equip_mode, param = uiSeeEquipGetEquipParamByPart(part);
	if equip_mode == nil then return end
	if equip_mode == EV_EQUIP_MODE_LOAD_SKIN then
		self:UnloadSkin(model_pre..part);
		if model == nil or model[1] == nil then
			self:UnloadSkin(model_pre..part);
		else
			self:LoadSkin(model_pre..part, model[1]);
			uiInfo("SKIN="..model[1]);
		end
	elseif equip_mode == EV_EQUIP_MODE_LINK then
		local slot = param.Slot;
		for i, s in ipairs(slot) do
			local short_name = model_pre..part..i;
			if model == nil or model[i] == nil then
				self:UnlinkModel(short_name);
			else
				local m = model[i];
				self:LinkModel(m, short_name, s);
				uiInfo("LINK="..m);
			end
		end
	elseif equip_mode == EV_EQUIP_MODE_LINK_WITH_PATH then
		local path = param.Path;
		self:LinkModel(path.Name, path_pre, path.Slot);
		local slot = param.Slot;
		for i, s in ipairs(slot) do
			local short_name = model_pre..part..i;
			local full_name = path_pre.."."..short_name;
			if model == nil or model[1] == nil then
				self:UnlinkModel(full_name);
			else
				local m = model[1];
				self:LinkSubModel(m, short_name, s, path_pre);
				uiInfo("EV_EQUIP_MODE_LINK_WITH_PATH="..m);
			end
		end
	end
end
function layWorld_frmItemlookEx_modelOther_Refresh(self)
	if self == nil then self = uiGetglobal("layWorld.frmItemlookEx.modelOther") end
	self:ClearModel();
	self:SetCameraEye(0, -80, 50, true);
	self:SetCameraLookAt(0, 0, 25);
	self:SetCameraUp(0, 0, 1);
	local model = uiSeeEquipGetCurModel();
	uiInfo("model="..model);
	if model == nil then return end
	local head, hair = uiSeeEquipGetCurAppearance();
	if head == nil then return end
	self:SetModel(model);
	self:LoadSkin("head", head);
	self:LoadSkin("hair", hair);
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_MAINTRUMP);			--������
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_SUBTRUMP1);            --��������1
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_SUBTRUMP2);            --��������2
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_CLOTHING);             --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_GLOVE);                --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_SHOES);                --Ь��
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_CUFF);                 --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_KNEEPAD);              --��ϥ
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_SASH);                 --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_RING1);                --��ָ1
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_RING2);                --��ָ2
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_AMULET1);              --�����1
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_AMULET2);              --�����2
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_PANTS);                --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_CLOAK);                --����
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_HELM);                 --ͷ��
	layWorld_frmItemlookEx_modelOther_RefreshPart(self, EV_EQUIP_PART_SHOULDER);             --����
end
-- ˢ������װ��
function TemplateBtnOtherEquip_RefreshAll()
	local form = uiGetglobal("layWorld.frmItemlookEx");
	for i = 0,12,1 do
		local btPart = SAPI.GetChild(form, "btPart"..i);
		TemplateBtnOtherEquip_Refresh(btPart); -- ���ˢ��
	end
	local modelOther = SAPI.GetChild(form, "modelOther");
	layWorld_frmItemlookEx_modelOther_Refresh(modelOther);
end
function TemplateBtnOtherEquip_OnLoad(self)
	self:RegisterScriptEventNotify("EVENT_SelfEnterWorld");
end
function TemplateBtnOtherEquip_OnEvent(self, event, Arg)
	if event == "EVENT_SelfEnterWorld" then
		local t_equip_part =
		{
			["btPart0"] = EV_EQUIP_PART_CLOTHING,	-- ����
			["btPart1"] = EV_EQUIP_PART_SASH,		--  ����
			["btPart2"] = EV_EQUIP_PART_CUFF,		--  ����
			["btPart3"] = EV_EQUIP_PART_GLOVE,		--  ����
			["btPart4"] = EV_EQUIP_PART_KNEEPAD,	--  ��ϥ
			["btPart5"] = EV_EQUIP_PART_MAINTRUMP,	--  ������
			["btPart6"] = EV_EQUIP_PART_SUBTRUMP1,	--  ��������
			["btPart7"] = EV_EQUIP_PART_SUBTRUMP2,	--  ��������
			["btPart8"] = EV_EQUIP_PART_SHOES,		--  Ь��
			["btPart9"] = EV_EQUIP_PART_AMULET1,	--  �����
			["btPart10"] = EV_EQUIP_PART_AMULET2,	--  �����
			["btPart11"] = EV_EQUIP_PART_RING1,		--  ��ָ
			["btPart12"] = EV_EQUIP_PART_RING2,		--  ��ָ
			["btPart13"] = EV_EQUIP_PART_CLOAK,		--  ��ָ
			["btPart14"] = EV_EQUIP_PART_HELM,		--  ��ָ
			["btPart15"] = EV_EQUIP_PART_SHOULDER,		--  ��ָ			
		}
		local name = self:getShortName();
		self:Set(EV_UI_EQUIP_PART_KEY, t_equip_part[name]);
	end
end
-- ����Hint
function TemplateBtnOtherEquip_OnHint(self)
	local part = self:Get(EV_UI_EQUIP_PART_KEY);
	if part == nil then self:SetHintRichText(0); return end
	local hint = uiSeeEquipGetEquipedItemHintByPart(part);
	if hint == nil then hint = 0 end
	self:SetHintRichText(hint);
end

function layWorld_frmItemlookEx_OnLoad(self)
	self:RegisterScriptEventNotify("EVENT_ItemSeeOtherEquipShow");
	self:RegisterScriptEventNotify("EVENT_OtherLeaveWorld");
end

function layWorld_frmItemlookEx_OnEvent(self, event, arg)
	if event == "EVENT_ItemSeeOtherEquipShow" then
		TemplateBtnOtherEquip_RefreshAll();
		self:ShowAndFocus();
	elseif event == "EVENT_OtherLeaveWorld" then
		if self:getVisible() == false then return end
		local ObjectId = arg[1];
		local CurObjectId = uiSeeEquipGetOtherObjectId();
		if CurObjectId == nil or CurObjectId == 0 or CurObjectId == ObjectId then
			self:Hide();
		end
	end
end

function layWorld_frmItemlookEx_OnShow(self)
	uiRegisterEscWidget(self);
end







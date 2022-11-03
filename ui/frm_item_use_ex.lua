Local_Item_UseItemDispatcher = -- ����ʹ�õķַ��� -- ָ�� ĳһ ���� ���� ʹ�÷�ʽ
{
	VarItemUse = 0,
	VarItemTarget = 0,
}

function Local_Item_UseItemDispatcher:Init()
	self:Reset();
	-- ע���Զ���Ĵ����� �ɷַ�ϵͳ������
	self[EV_ITEM_TYPE_CLEARTALENTS]			= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CLEARTALENTS			;		-- ����ϴ���
	self[EV_ITEM_TYPE_GREENTOBLUE]			= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GREENTOBLUE				;		-- ��ɫװ��ת������ɫ
	self[EV_ITEM_TYPE_GEMMY]				= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GEMMY					;		-- ��Ƕ�õ�ħʯ
	self[EV_ITEM_TYPE_GEMMYCLEAR]			= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GEMMYCLEAR				;		-- �ƻ�ħʯ��Ƕ
	self[EV_ITEM_TYPE_ENCHANTCLEAR]			= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_ENCHANTCLEAR			;		-- �������
	self[EV_ITEM_TYPE_BULLETINTOUSER]		= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_BULLETINTOUSER			;		-- ���͹�������
	self[EV_ITEM_TYPE_SMALLPETPOINTSCLEAR]	= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_SMALLPETPOINTSCLEAR		;		-- С����ϴ�����
	self[EV_ITEM_TYPE_CALLFRIEND]			= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CALLFRIEND				;		-- �ٻ���ҵ��Լ����
	self[EV_ITEM_TYPE_CHANGESMALLPETAPPEARANCE]	= Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CHANGESMALLPETAPPEARANCE				;		-- �ı�С��������
end

function Local_Item_UseItemDispatcher:Reset()
	self.VarItemUse = 0;
	self.VarItemTarget = 0;
	--uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
end

function Local_Item_UseItemDispatcher:IsProcessing()
	if self.VarItemUse == 0 or uiGetGameCursor() == EV_GAME_CURSOR_NORMAL then
		return false;
	end
	return true;
end

function Local_Item_UseItemDispatcher:Use(id, usetoself) -- idΪ���ߵ�ObjectId

	if LClass_ItemFreezeManager:IsFreezed(id) == true then
		return;
	end
	self.VarItemUse = id;
	local objInfo, classInfo = self:GetUseItemInfo();
	if objInfo == nil then
		self:Reset();
		return false;
	end
	--[[
	if usetoself then
		if classInfo["m_UseParam.TargetType"] == 1 then
			local myObjectId = uiGetMyInfo("ObjectId");
			return self:Target(myObjectId);
		end
		self:Reset();
		return false;
	end
	]]
	local Type = classInfo.Type;
	if self[Type] == nil then Type = "_Default_" end -- ���û��ע���Ӧ�ĺ���,��ʹ��Ĭ�Ϻ���
	return self[Type](self, 1);
end

function Local_Item_UseItemDispatcher:Target(targetid) -- idΪĿ����ߵ�ObjectId
	self.VarItemTarget = targetid;
	local objInfo, classInfo = self:GetUseItemInfo();
	if objInfo == nil or classInfo == nil or self[classInfo.Type] == nil then
		self:Reset();
		return false;
	end
	return self[classInfo.Type](self, 2);
end

function Local_Item_UseItemDispatcher:Release(param) -- param ���� ��ͬ�ĵ��� ���������ͺ�������ܲ��� ֻΪ����uiItemReleaseItem׼��
	local bResult = false;
	if param == nil then param = 0 end
	local objInfo, classInfo = self:GetUseItemInfo();
	if objInfo == nil then return false end
	local id, Type, Bind, Name = objInfo.ObjectId, classInfo.Type, objInfo.Bind, classInfo.Name;
	
	if LClass_ItemFreezeManager:IsFreezed(id) == true then
		return;
	end
	
	if Bind == EV_ITEM_BIND_EQUIP then
		-- ��ʾ ��� ���� �����󽫰�
		local title = "";
		local msg = "";
		if Type == EV_ITEM_TYPE_MAINTRUMP or Type == EV_ITEM_TYPE_SUBTRUMP then
			msg = string.format(LAN("MSG_EQUIP_CONFIRM"), Name);
		else
			msg = string.format(LAN("MSG_ITEM_USE_CONFIRM"), Name);
		end
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			item		=	id,
			param		=	param,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) uiItemReleaseItem(Arg.item, Arg.param) end, nil, MsgArg);
		bResult = true;
	else
		bResult = uiItemReleaseItem(id, param);
	end
	self:Reset();
	return bResult;
end

function Local_Item_UseItemDispatcher:GetItemInfo(id)
	if id == nil or id == 0 then return nil end
	local objInfo = uiItemGetBagItemInfoByObjectId(id);
	if objInfo == nil then return nil end
	local index = objInfo.TableId; -- ���߱��id
	if index == nil or index == 0 then return nil end
	local classInfo = uiItemGetItemClassInfoByTableIndex(index);
	if classInfo == nil then return nil end
	return objInfo, classInfo;
end

function Local_Item_UseItemDispatcher:GetUseItemInfo()
	return self:GetItemInfo(self.VarItemUse);
end

function Local_Item_UseItemDispatcher:GetTargetItemInfo()
	return self:GetItemInfo(self.VarItemTarget);
end

-- Ĭ�ϵĴ���
function Local_Item_UseItemDispatcher:_Default_()
	local objInfo, classInfo = self:GetUseItemInfo();
	if objInfo == nil then return false end
	if classInfo == nil then return false end
	local ItemUseMessage = classInfo.ItemUseMessage;
	if ItemUseMessage and type(ItemUseMessage) == "string" and ItemUseMessage ~= "" then
		---------------  ��ʾ���  -----------------
		local msg1 = string.format(LAN("item_check_use_item"), classInfo.Name);
		local msg = string.format("%s\n\n%s", msg1, ItemUseMessage);
		local title = "";
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		return false;
	end
	return self:Release();
end
-- ����ϴ��� -- 91 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CLEARTALENTS (self, step) -- �ڶ�������Ϊ���� (1:ʹ�õ��� 2:ѡ��Ŀ��)
	local UseCursor = EV_GAME_CURSOR_MINE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then -- �ڶ���,ѡ��Ŀ��
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		local objInfo, classInfo = self:GetTargetItemInfo();
		if objInfo == nil then return false end
		---------------  ��ʼ���  -----------------
		-- ���Ŀ���������
		if (classInfo.Type ~= EV_ITEM_TYPE_MAINTRUMP and classInfo.Type ~= EV_ITEM_TYPE_SUBTRUMP) then
			uiClientMsg(LAN("msg_talent_can_not"), true); -- Ŀ������Ƿ�����
			return false;
		end
		-- ���Ŀ����ߵļӵ����
		if (objInfo.WeaponTalentSize == 0) then
			uiClientMsg(LAN("msg_talent_notalents"), true); -- �������û���������κ��츳��
			return false;
		end
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("msg_talent_clear_sure"), TargetName); -- ��ȷ��Ҫ����[%s]���츳��
		---------------  ��ʾ���  -----------------
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarItemTarget,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return true;
	end
	return false;
end
-- ��ɫװ��ת������ɫ -- 53 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GREENTOBLUE(self, step)
	local UseCursor = EV_GAME_CURSOR_MINE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then -- �ڶ���,ѡ��Ŀ��
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		local objInfoUse, classInfoUse = self:GetUseItemInfo();
		if objInfoUse == nil then return false end
		local objInfo, classInfo = self:GetTargetItemInfo();
		if objInfo == nil then return false end
		---------------  ��ʼ���  -----------------
		-- ���Ŀ���������
		if (classInfo.Type < EV_ITEM_TYPE_EQUIP_MIN or classInfo.Type >= EV_ITEM_TYPE_EQUIP_MAX) then
			uiClientMsg(LAN("msg_gtob_must_weaarm"), true); -- Ŀ������Ƿ�����װ����
			return false;
		end
		-- ���Ŀ�������ɫ
		local list = SAPI.SplitString(classInfoUse.OtherParam2, ";");
		local index = SAPI.GetIndexInTable(list, tostring(objInfo.Color));
		if index == nil or index == 0 then
			uiClientMsg(LAN("msg_gtob_must_green"), true);
			return false;
		end
		-- ���Ŀ������Ƿ��װ��
		local bCanEquip, strError = uiItemCheckBagItemEquipCondition(self.VarItemTarget);
		if bCanEquip == false then
			uiClientMsg(LAN("msg_gtob_must_canequip"), true);
			return false;
		end
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("msg_gtob_ask"), TargetName); -- ��ȷ��Ҫת��[%s]��������
		---------------  ��ʾ���  -----------------
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarItemTarget,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return true;
	end
	return false;
end
-- ��Ƕ�õ�ħʯ -- 54 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GEMMY(self, step)
	local UseCursor = EV_GAME_CURSOR_MINE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then -- �ڶ���,ѡ��Ŀ��
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		local objInfoUse, classInfoUse = self:GetUseItemInfo();
		if objInfoUse == nil then return false end
		local objInfo, classInfo = self:GetTargetItemInfo();
		if objInfo == nil then return false end
		---------------  ��ʼ���  -----------------
		-- ����Ƿ������Ƕ
		local bCanGemmy, strError = uiItemCheckBagItemGemmyItem(self.VarItemTarget, self.VarItemUse);
		if bCanGemmy == false then
			if strError ~= nil and string.len(strError) > 0 then
				uiClientMsg(strError, true);
			end
			return false;
		end
		local day = tonumber(classInfoUse.InitData) / 24;
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("msg_gemmy_ask"), TargetName, day); -- ��Ƕ��ħʯ������[%s]�ϣ�%d��֮��������Զ���ʧ��������ȷ��Ҫ��������
		---------------  ��ʾ���  -----------------
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarItemTarget,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return true;
	end
	return false;
end
-- �ƻ�ħʯ��Ƕ -- 57 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_GEMMYCLEAR(self, step)
	local UseCursor = EV_GAME_CURSOR_MINE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then -- �ڶ���,ѡ��Ŀ��
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		local objInfo, classInfo = self:GetTargetItemInfo();
		if objInfo == nil then return false end
		---------------  ��ʼ���  -----------------
		-- ����Ƿ������Ƕ
		local bCanClear, strError = uiItemCheckBagItemGemmyClear(self.VarItemTarget, self.VarItemUse);
		if bCanClear == false then
			if strError ~= nil and string.len(strError) > 0 then
				uiClientMsg(strError, true);
			end
			return false;
		end
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("msg_gemmy_clear_ask"), TargetName); -- ��ȷ��Ҫ�ƻ���[%s]�ϵ�ħʯ��������
		---------------  ��ʾ���  -----------------
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarItemTarget,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return true;
	end
	return false;
end
-- ������� -- 106 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_ENCHANTCLEAR(self, step)
	local UseCursor = EV_GAME_CURSOR_MINE;
	if step == 1 then -- ��һ��,ʹ�õ���
		return uiSetGameCursor(UseCursor);
	elseif step == 2 then -- �ڶ���,ѡ��Ŀ��
		local cursor = uiGetGameCursor();
		if cursor ~= UseCursor then return false end -- ��鵱ǰͼ��״̬
		local objInfo, classInfo = self:GetTargetItemInfo();
		if objInfo == nil then return false end
		---------------  ��ʼ���  -----------------
		-- ����Ƿ���Խ������
		local bCanClear, strError = uiItemCheckBagItemEnchantClear(self.VarItemTarget, self.VarItemUse);
		if bCanClear == false then
			if strError ~= nil and string.len(strError) > 0 then
				uiClientMsg(strError, true);
			end
			return false;
		end
		---------------  ���ͨ��  -----------------
		local TargetName = classInfo.Name;
		local title = "";
		local msg = string.format(LAN("msg_enchant_clear_ask"), TargetName); -- ��ȷ��Ҫ�����[%s]�����������
		local form = uiMessageBox(msg, title, true, true, true);
		local MsgArg = -- ����MessageBox����ʱ����
		{
			Dispatcher	=	self;
			param		=	self.VarItemTarget,
		}
		SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release(Arg.param) end, nil, MsgArg);
		uiSetGameCursor(EV_GAME_CURSOR_NORMAL);
		return true;
	end
	return false;
end
-- ���͹������� -- 58 -- �Ѳ��� -- ����
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_BULLETINTOUSER(self, step)
	local frmBlessingsCard = uiGetglobal("layWorld.frmBlessingsCard");
	layWorld_frmBlessingsCard_OnEvent(frmBlessingsCard, "EVENT_ItemUseIndirect", {self.VarItemUse});
	return true;
end
-- С����ϴ����� -- 107
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_SMALLPETPOINTSCLEAR(self, step)
	local title = "";
	local msg = string.format(LAN("MSG_CLEARSMALLPETPOINTS_ASK")); -- ��ȷ��Ҫ�������ǰС��������Ե�����
	local form = uiMessageBox(msg, title, true, true, true);
	local MsgArg = -- ����MessageBox����ʱ����
	{
		Dispatcher	=	self;
	}
	SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release() end, nil, MsgArg);
	return true;
end
-- �ٻ���ҵ��Լ���� --
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CALLFRIEND(self, step)
	local title = "";
	local msg = string.format(LAN("msg_input_callfriend")); -- ��������Ҫ�ٻ�����ҵ����֣�
	local form = uiInputBox(msg, title, "", true, true, true);
	local MsgArg = -- ����MessageBox����ʱ����
	{
		Dispatcher	=	self;
	}
	SAPI.AddDefaultInputBoxCallBack(form, function(Event, Arg, text) Arg.Dispatcher:Release(text) end, nil, MsgArg);
	return true;
end
-- �ı�С�������� -- 150
function Local_Item_UseItemDispatcher_EV_ITEM_TYPE_CHANGESMALLPETAPPEARANCE(self, step)
	local objInfoUse, classInfoUse = self:GetUseItemInfo();
	if not objInfoUse then return false end

	--local LastTime = tonumber(classInfoUse.OtherParam2);
	local modelid = tonumber(classInfoUse.OtherParam1);
	--if not LastTime or not modelid then return false end
	
	local id = uiUserGetCurrentNonCombatPetInfo();
	if not id then uiClientMsg(LAN("msg_change_smallpet_appearance1"), false) return false end -- ������С����ų�������²���ʹ�øõ���

	local modelInfo = uiModel_GetModelInfo(modelid);
	if not modelInfo then return false end

	--local year, month, day, hour, minute, second = uiFormatTime(uiGetServerTime() + LastTime);
	
	local title = "";
	local msg = string.format(LAN("msg_change_smallpet_appearance2"), modelInfo.Name); -- �����ѵ�ǰС��������%s�����ԭ���б���Ч�����������ǣ���ȷ��
	
	local form = uiMessageBox(msg, title, true, true, true);
	local MsgArg = -- ����MessageBox����ʱ����
	{
		Dispatcher	=	self;
	}
	SAPI.AddDefaultMessageBoxCallBack(form, function(Event, Arg) Arg.Dispatcher:Release() end, nil, MsgArg);
	return true;
end














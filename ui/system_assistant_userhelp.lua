
local AllowedTaskId =
{
	list = {464,551,553,555,556,557,558,559,560,561,11,25,853},
	IsAllowed = function(self, id)
		return SAPI.ExistInTable(self.list, id);
	end,
	Size = function(self)
		return table.getn(self.list);
	end
};
local AllowedItemId =
{
	-- 350	- СĢ������	
	-- 355	- ��Ģ������	
	-- 3010 - ��Ѫ����
	list = {3010,350,352,6264--[[7000,7018,7016,7101,7228]]},
	related_task =
	{
		[350] = 25,	-- �������
		[352] = 25,	-- �������
		[6264] = 559, -- �������
	--[[
		[7000] = 2,	--����2 - ����7000
		[7018] = 4, --����4 - ���������7018
		[7016] = 5, --����5 - �ް�7016
		[7101] = 93, --����93 - ǧ��ҹ����Ĵ�˵7101
		[7228] = 483, --����483 - ��ͨ�����7228
	]]
	},
	IsAllowed = function(self, id)
		return SAPI.ExistInTable(self.list, id);
	end,
	GetRelatedTaskId = function (self, id)
		return self.related_task[id];
	end,
	Size = function(self)
		return table.getn(self.list);
	end
};
local AllowedItemId_Pos = 
{
	-- 3010 - ��Ѫ����
	-- 801	- ������
	list = {3010,801},
	IsAllowed = function(self, id)
		return SAPI.ExistInTable(self.list, id);
	end,
	Size = function(self)
		return table.getn(self.list);
	end
};
local function RefreshSystemValue_Task(id)
	if id == nil then
		-- ˢ������
		for i, v in ipairs(AllowedTaskId.list) do
			RefreshSystemValue_Task(v);
		end
		return;
	end
	local SysPtr = uiUserHelpGetSystemPtr();
	if AllowedTaskId:IsAllowed(id) then
		if uiTaskIsFinished(id) then
			SysPtr:Set("task"..id, 3);
		elseif uiTaskIsDoing(id) then
			if uiTaskCanFinishTask(id) then
				SysPtr:Set("task"..id, 2);
			else
				SysPtr:Set("task"..id, 1);
			end
		else
			SysPtr:Set("task"..id, 0);
		end
	end
end

local function RefreshSystemValue_Item(id)
	if id == nil then
		-- ˢ������
		for i, v in ipairs(AllowedItemId.list) do
			RefreshSystemValue_Item(v);
		end
		return;
	end
	local SysPtr = uiUserHelpGetSystemPtr();
	if AllowedItemId:IsAllowed(id) then
		local count = uiGetBagItemInfoByTableIndex(id);
		if not count or count <= 0 then count = 0 end
		SysPtr:Set("item"..id, count);
		local RelatedTaskId = AllowedItemId:GetRelatedTaskId(id);
		if RelatedTaskId then
			RefreshSystemValue_Task(RelatedTaskId);
		end
	end
end

local function RefreshSystemValue_ItemPos(id)
	if id == nil then
		-- ˢ������
		for i, v in ipairs(AllowedItemId_Pos.list) do
			RefreshSystemValue_ItemPos(v);
		end
		return;
	end
	local SysPtr = uiUserHelpGetSystemPtr();
	if AllowedItemId_Pos:IsAllowed(id) then
		local count, objId = uiGetBagItemInfoByTableIndex(id);
		local pos = "unknown"; -- ��������ǿ��ַ����Ļ������ʽ�ᵱ��
		if objId and objId > 0 then
			local bag, line, col = uiItemGetItemCoordByObjectId(objId);
			pos = GetItemButtonNameByCoord(bag, line, col);
		end
		SysPtr:Set("itembutton"..id, pos);
	end
end

local function RefreshSystemValue_ItemBag()
	local combagfreesize=0;
	local count = uiItemGetItemBagCount();
	local SysPtr = uiUserHelpGetSystemPtr();
	for i = 0, count-1, 1 do
		local line, col, itemcount, istask, isoutdate = uiItemGetItemBagInfoByIndex();
		if not istask and not isoutdate then
			combagfreesize = combagfreesize + line * col - itemcount;
		end
	end
	SysPtr:Set("combagfreesize", combagfreesize);
end

function laySystemAssistant_UserHelp_OnLoad(self)

	-- ע�����Ȥ����Ϣ
	self:RegisterScriptEventNotify("EVENT_SelfLevelUp");
	self:RegisterScriptEventNotify("EVENT_SelfEnterWorld");
	self:RegisterScriptEventNotify("event_update_task");		-- �������
	self:RegisterScriptEventNotify("EVENT_SelfDie");
	self:RegisterScriptEventNotify("EVENT_ON_USER_AUTO_WALK")
	
	self:RegisterScriptEventNotify("bag_item_update");			-- ���߸���
	self:RegisterScriptEventNotify("bag_item_removed");			-- �����Ƴ�
	self:RegisterScriptEventNotify("bag_item_added");			-- �������
	self:RegisterScriptEventNotify("bag_item_exchange_grid");	-- ����λ�ñ任
	
	self:RegisterScriptEventNotify("TargetChanged");		-- Ŀ��ı�
	
	self:RegisterScriptEventNotify("EVENT_TeamRefresh");		-- ����ˢ��
	
	self:RegisterScriptEventNotify("RefreshStall");				--ˢ���Լ�̯λ����
    self:RegisterScriptEventNotify("RefreshOtherStall");		--ˢ��Ŀ��̯λ����
    self:RegisterScriptEventNotify("EVENT_SelfStallStateChanged"); --�Լ�̯λ״̬�ı�
    self:RegisterScriptEventNotify("EVENT_OtherStallStateChanged"); --Ŀ��̯λ״̬�ı�
	
	self:RegisterScriptEventNotify("EVENT_SelfEquipmentChanged");
	self:RegisterScriptEventNotify("EVENT_SelfEquipmentEquiped");
	self:RegisterScriptEventNotify("EVENT_SelfEquipmentUnequiped");

end

function laySystemAssistant_UserHelp_OnEvent(self, event, args)

	-- �յ�����Ȥ����Ϣ��������ϵͳ�����ö�Ӧ��ֵ���Թ����ʾ�����������ط�ʹ��
	local SysPtr = uiUserHelpGetSystemPtr();
	if not SysPtr then
		return
	else
		if event == "EVENT_SelfLevelUp" then
			local level = uiGetMyInfo("Exp");
			SysPtr:Set("Level", level);
		elseif event == "event_update_task" then		-- �������
			RefreshSystemValue_Task();
		elseif event == "bag_item_update" or event == "bag_item_added" then
			local _, tableid = uiItemGetItemInfoByCoord(args[2], args[3], args[4]);
			RefreshSystemValue_Item(tableid);
			RefreshSystemValue_ItemPos(tableid);
			RefreshSystemValue_ItemBag();
		elseif event == "bag_item_removed" then
			local tableid = args[6];
			RefreshSystemValue_Item(tableid);
			RefreshSystemValue_ItemPos(tableid);
			RefreshSystemValue_ItemBag();
		elseif event == "bag_item_exchange_grid" then
			local _, tableid = uiItemGetItemInfoByCoord(args[2], args[3], args[4]);
			RefreshSystemValue_ItemPos(tableid);
			local _, tableid = uiItemGetItemInfoByCoord(args[5], args[6], args[7]);
			RefreshSystemValue_ItemPos(tableid);
			RefreshSystemValue_ItemBag();
		elseif event == "TargetChanged" then
			local id = uiUserGetNpcTargetInfo();
			if id == nil then id = 0 end
			SysPtr:Set("targetid", id);
		elseif event == "EVENT_TeamRefresh" then
			local teamcount = uiTeamGetCount();
			if teamcount == nil then teamcount = 0 end
			SysPtr:Set("teamsize", teamcount);
		elseif event == "RefreshStall" then
			local objlist=uiStallGetSaleItemList();
			local number=0;
			if objlist then
				number=table.getn(objlist);
			end
			SysPtr:Set("stallitemcount",number);
		elseif event == "RefreshOtherStall" then
			local objlist=uiStallGetOtherSaleItemList();
			local number=0;
			if objlist then
				number=table.getn(objlist);
			end
			SysPtr:Set("otherstallitemcount",number);
		elseif event == "EVENT_SelfStallStateChanged" then
			if uiStallIsStall() == true then
				SysPtr:Set("stallstate",1);
			else
				SysPtr:Set("stallstate",0);
			end
		elseif event == "EVENT_OtherStallStateChanged" then
			if uiStallOtherIsStall() == true then
				SysPtr:Set("otherstallstate",1);
			else
				SysPtr:Set("otherstallstate",0);
			end
		elseif event == "EVENT_SelfEnterWorld" then
			local level = uiGetMyInfo("Exp");
			SysPtr:Set("Level", level);
			RefreshSystemValue_Item();
			RefreshSystemValue_ItemPos();
			RefreshSystemValue_ItemBag();
			SysPtr:Set("targetid", 0);
			SysPtr:Set("teamsize", 0);
			SysPtr:Set("stallitemcount",0);
			SysPtr:Set("stallstate",0);
		elseif event == "EVENT_SelfDie" then
			SysPtr:Set("Die", 1);
		elseif event == "EVENT_ON_USER_AUTO_WALK" then
			SysPtr:Set("AutoWalk", 1)
		elseif event == "EVENT_SelfEquipmentChanged" then
			RefreshSystemValue_Task(853);
		elseif event == "EVENT_SelfEquipmentEquiped" then
			RefreshSystemValue_Task(853);
		elseif event == "EVENT_SelfEquipmentUnequiped" then
			RefreshSystemValue_Task(853);
		end
	end

end


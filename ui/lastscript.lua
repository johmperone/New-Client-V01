


local hidelist = 
{
};

--------------- ��ҪHide�Ŀؼ�ȫ·���������������б��У���ʽ����
--	local hidelist = 
--	{
--		"layWorld.XXXXX",
--		"layWorld.YYYYY",
--	};
--
--
--







--------------- �����ǳ���ʵ��

local op = nil;
local function Hide(name)
	op = uiGetglobal(name)
	if op == nil then
		uiError (string.format("widget not find error [%s]", name))
		return false;
	end
	op:Hide();
	return true;
end

for i, v in ipairs(hidelist) do
	print(Hide(v))
end

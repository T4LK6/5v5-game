--!strict
-- Shared context handed to every page builder.

export type Ctx = {
	-- Show a toast notification.
	toast: (title: string, body: string, accent: Color3?) -> (),
	-- Switch to another top-level page by name.
	goTo: (name: string) -> (),
	-- Fake "invite friend" action for a party slot.
	invite: (slot: number) -> (),
}

return {}

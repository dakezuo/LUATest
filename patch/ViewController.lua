waxClass{"ViewController",UIViewController}
IBOutlet "label"
-- function viewDidLoad(self)

-- print(viewDidLoad)

-- end

function viewDidLoad(self)

print(112)
self.super:viewDidLoad(self)
	self.label:setColor(UIColor:greenColor())
	self.label:setText("我还有俩只视野,从来也不插0_0")
print(113)

end

-- function viewDidLoad(self)
-- 	self.super:viewDidLoad(self)
-- 	self.label:setColor(UIColor:greenColor())
-- 	self.label:setText("我还有俩只视野,从来也不插0_0")
-- end

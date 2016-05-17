waxClass{"ViewController",UIViewController}
require "OneViewController"
-- IBOutlet "label"
-- function viewDidLoad(self)

-- print(viewDidLoad)

-- end

function viewDidLoad(self)

print(112)
self.super:viewDidLoad(self)
	self:label():setBackgroundColor(UIColor:greenColor())
	self:label():setText("我还有俩只视野,从来也不插0_0")

    local evalButton = UIButton:buttonWithType(UIButtonTypeRoundedRect)

   evalButton:setTitle_forState('Evaluate', UIControlStateNormal)

    evalButton:setFrame(CGRect(200,142, 100, 32))

   evalButton:addTarget_action_forControlEvents(self, 'eval:',

                           UIControlEventTouchUpInside)

   self.evalButton = evalButton

   self:view():addSubview(self.evalButton)
print(113)

end

function eval(self, sender)

	local OneViewController = OneViewController.init(OneViewController)
	self:navigationController():pushViewController(OneViewController)_animated(yes)
   

end

-- function viewDidLoad(self)

-- print(112)
-- self.super:viewDidLoad(self)
-- 	local label = UILabel:initWithFrame(CGRect(0, 100, 320, 35))  
--     label:setFont(UIFont:boldSystemFontOfSize(30))  
--     label:setColor(UIColor:whiteColor())  
--     label:setBackgroundColor(UIColor:colorWithRed_green_blue_alpha(0.545, 0.3, 1, 1))  
--     label:setText("前方高能：")  
--     label:setTextAlignment(UITextAlignmentCenter)  
--     self:view():addSubview(label)  
-- print(113)

-- end


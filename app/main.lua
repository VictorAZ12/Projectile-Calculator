--Student Number: 10491666
--Student Name: Yanchen Zhao

-- require display information
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local contentWidth = display.contentWidth
local contentHeight = display.contentHeight


--initialize parameters
local angleInput
local velocityInput
local rangeInput
local angleInputStatus = false
local velocityInputStatus = false
local rangeInputStatus = false
-- initialize anchors and widgets 
local angleFieldX = centerX
local angleFieldY = math.ceil(contentHeight/3*2 + 20)
local velocityFieldX = math.ceil(contentWidth/4)
local velocityFieldY = angleFieldY
local rangeFieldX = math.ceil(contentWidth*3/4)
local rangeFieldY = angleFieldY


-- set status bar to hidden
display.setStatusBar( display.HiddenStatusBar )


-- angleField listener
local angleField
local function angleListener( event )
    if ( event.phase == "submitted" ) then
        angleInput=tonumber(angleField.text) --assign input to the variable
        angleInputStatus=true
    end
end
-- Create angle field
angleField = native.newTextField( angleFieldX, angleFieldY, math.ceil(contentWidth/4 -10), math.ceil(contentHeight/20) )
angleField.inputType = "decimal"
angleField:addEventListener( "userInput", angleListener )
-- Create title for angle field
local angleText = display.newText({
    text = "Angle\n(degrees)",
    x = angleFieldX,
    y = angleFieldY + math.ceil(contentHeight/15),
    font = native.systemFont,
    fontSize = math.ceil(contentHeight/40),
    align = "center"
})

-- velocityField listener
local velocityField
local function velocityListener( event )
    if ( event.phase == "submitted" ) then
        velocityInput=tonumber(velocityField.text) --assign input to the variable
        velocityInputStatus=true
    end
end
-- Create velocity textfield
velocityField = native.newTextField( velocityFieldX, velocityFieldY, math.ceil(contentWidth/4 - 10), math.ceil(contentHeight/20) )
velocityField.inputType = "decimal"
velocityField:addEventListener( "userInput", velocityListener )
local velocityText = display.newText({
    text = "Velocity\n(m/s)",
    x = velocityFieldX,
    y = velocityFieldY + math.ceil(contentHeight/15),
    font = native.systemFont,
    fontSize = math.ceil(contentHeight/40),
    align = "center"
})

-- rangeField listener
local rangeField
local function rangeListener( event )
    if ( event.phase == "submitted" ) then
        rangeInput=tonumber(rangeField.text) --assign input to the variable
        rangeInputStatus=true
    end
end
-- Create range textfield
rangeField = native.newTextField( rangeFieldX, rangeFieldY, math.ceil(contentWidth/4 - 10), math.ceil(contentHeight/20) )
rangeField.inputType = "decimal"
rangeField:addEventListener( "userInput", rangeListener )
local rangeText = display.newText({
    text = "Range\n(m)",
    x = rangeFieldX,
    y = rangeFieldY + math.ceil(contentHeight/15),
    font = native.systemFont,
    fontSize = math.ceil(contentHeight/40),
    align = "center"
})

function parabolaCalc(velocityInput, angleInput, rangeInput, type) --start from type 1
    --Initilize constents of projectile formula 
    --Assmuing that x and y are the coordinates of pixels
    -- assumuing that up and right are positive, down and left are negative
    local g = 9.81 -- gravity : 9.81 m/s^2
    local m = 43.091 -- mass: 43.091 kg
    -- parabola = ax^2 + bx, assuming the staring point is (0, 0)
    local a
    local b
    -- velocity, angle alpha and range
    local v=0 
    local alpha -- alpha in radians
    local range
    local maxRange --only used in type 2 and type 3
    local height
    local sinA
    local sin2A
    local cosA
    --points on parabola diagram
    local x
    local y
    --flag to indicate if the calculation is succeeded
    local flag = false
    --Type 1: velocity and angle are known, range is unknown
    if (type == 1) then
        -- v and alpha are initial velosity and angle 
        v = velocityInput -- always positive
        -- convert degrees to radius
        alpha = math.rad(angleInput)
        sin2A = math.sin(2*alpha)
        sinA = math.sin(alpha)
        cosA = math.cos(alpha)
        -- calculate range 
        range = v*v*sin2A/g
        flag=true
    --Type 2: velocity and range is known, angle is unknown
    elseif (type == 2) then
        -- check if the range is valid b
        v=velocityInput
        range=rangeInput
        --check if the given velocity can reach the range
        -- max possible range at this speed: angle=45
        maxRange=v*v/g
        if (range > maxRange) then
            return nil, nil, nil, nil, nil, flag
        end
        sin2A = range*g/(v*v)
        alpha = (math.pi-math.asin(sin2A)) / 2
        sinA = math.sin(alpha)
        cosA = math.cos(alpha)
        flag=true
    --Type 3: angle and range is known, velocity is unknown
    elseif (type == 3) then
        alpha=math.rad(angleInput)
        sinA = math.sin(alpha)
        sin2A=math.sin(alpha*2)
        cosA = math.cos(alpha)
        range=rangeInput
        --calculate velocity
        v=math.sqrt(range*g/sin2A)
        flag=true
    end
    --apex height
    height = v*v*sinA*sinA/(2*g)
    --calculate a and b using parabola's properties
    b = 4*height/range
    a = -4*height/(range*range)
   
    return v, 360*alpha/(2*math.pi), range, height, a, b, flag
end
function parabolaPrint(a,b, range, diagram, diagramHeight, scaleX, scaleY)
    --print image using y=ax^2 + bx
    for x=0, math.ceil(range),1 do
        y = a*x*x + b*x
        local point=display.newRect(x*scaleX, diagramHeight-y*scaleY, 1, 1)
        point:setFillColor(0,0,1)
        diagram:insert(point)
    end
end

--function to create / draw trajectory with air resistance
function trajectoryCalc(velocityInput, angleInput, draw, diagram, diagramHeight, scaleX, scaleY) --start from type 1
    --Initilize constents of projectile formula 
    --Assmuing that x and y are the coordinates of pixels
    -- assumuing that up and right are positive, down and left are negative
    local g = 9.81 -- gravity : 9.81 m/s^2
    local rho = 1.2041 -- air density: 1.2041 Kg/m^3
    local r = 1.55 / 2 -- radius of shell: 1.55/2 = 0.775 m
    local A = r*r*math.pi --cross-sectional area of shell
    local D = 0.0028342 --drag coefficient, calculated from unit test 1
    local k = 0.5*rho*D*A -- Fd = 0.5*rho*D*A*v*v = k*v*v, since 0.5*rho*D*A is a constant
    local m = 43.091 -- mass: 43.091 kg
    -- formula test: air resistance enabled
    -- v and alpha are initial velosity and angle 
    local v = velocityInput -- always positive
    local alpha = angleInput -- range=8000 t=17
    -- convert degrees to radius
    alpha = math.rad(alpha)
    local range = 0
    local dt=0.01 --delta t = 0.01s
    -- current coordinate
    local x=0
    local y=0
    local maxHeight=y --the apex that the trajectory reaches
    -- trajectory
    for t = 1, 10000000 do --assuming the maximum flight time is 10000 seconds
        -- calculation of drag, delta X, delta Y
        local Fd = k*v*v --drag force
        local cosA = math.cos(alpha) -- consine value of angle Alpha
        local sinA = math.sin(alpha)
        local dX = v * cosA * dt - 0.5 * dt * dt * (Fd * cosA / m) --horizontal delta X
        local dY = v * sinA * dt - 0.5 * dt * dt * (Fd * sinA / m + g) --horizontal delta Y, gravity is positive
        -- change of range and coordinates
        range = range + dX
        x = x + dX 
        y = y + dY
        if (y>maxHeight) then
            maxHeight=y
        end
        -- reach the ground, return range
        if y <= 0 then
            return range,maxHeight
        end
        -- --Draw == true: draw points on screen while calculating each point
        if draw then
            local point=display.newRect(x*scaleX, diagramHeight-y*scaleY, 1, 1)
            point:setFillColor(1,0,0)
            diagram:insert(point)
        end
        -- calculation of next time, angle and velosity: angle = arctan(vy/vx), v = vx / cosA
        local vy = v * sinA - (Fd * sinA / m + g) * dt 
        local vx = v * cosA - (Fd * cosA / m) * dt
        alpha = math.atan(vy / vx)
        v = vx / math.cos(alpha)
        t=t+1
    end
end

-- function to search an angle for trajectory - type 2
function searchTrajectory(velocity, angle, maxRange)
    local foundFlag=false
    --attempt to calculate a angle for trajectory based on angle
    local angleOffset=0
    local leftRange=0
    local rightRange=0
    local angleFlagRight=false --flags to determine the offset
    local angleFlagLeft=false
    local anglePotential=0
    local leftTemp=0
    local rightTemp=0
    local trajectoryHeight
    --search precision: 1 degree (decreasing)
    for i=0,90 do
        angleOffset=i
        if(angle-angleOffset>0)then
            rightRange, trajectoryHeight=trajectoryCalc(velocity, angle-angleOffset, false, diagram, diagramHeight, scaleX, scaleY)
        end
        --determine if the new range is incresed
        if(rightRange>=maxRange) then
            anglePotential=angle-angleOffset
            angleFlagRight=true --found flag by decreasing the angle
            foundFlag=true
            trajectoryRange=rightRange
            break
        end
    end
    --an angle exists by decreasing the parabola angle, change search precision to 0.1 degree (increasing)
    if(angleFlagRight) then
    --reset all flags
        angleOffset=0
        leftRange=0
        for i=0.1,1, 0.1 do --precision: 0.1 degree
            angleOffset=i
            if(anglePotential+angleOffset<90)then
                leftRange, trajectoryHeight=trajectoryCalc(velocity, anglePotential+angleOffset, false, diagram, diagramHeight, scaleX, scaleY)
                --determine if the new range is incresed
            end
            if(leftRange<=maxRange) then
                local leftError=math.abs(leftRange-maxRange)
                local rightError=math.abs(leftTemp-maxRange)
                if leftError>=rightError then
                    anglePotential=anglePotential+angleOffset
                    trajectoryAngle=anglePotential
                    trajectoryRange=leftRange
                    break
                else
                    anglePotential=anglePotential+angleOffset-0.1
                    trajectoryAngle=anglePotential
                    trajectoryRange=leftTemp
                    break
                end
            end
            if(i==0.1)then
                leftTemp=leftRange
                elseif(leftRange<leftTemp)then
                leftTemp=leftRange
            end
        end
    end

    --search precision: 1 degree (increasing)
    for i=0,90 do
        angleOffset=i
        if(angle+angleOffset<0)then
            leftRange, trajectoryHeight=trajectoryCalc(velocity, angle+angleOffset, false, diagram, diagramHeight, scaleX, scaleY)
        end
        --determine if the new range is incresed
        if(leftRange>=maxRange) then
            anglePotential=angle+angleOffset
            angleFlagLeft=true --found trajectory angle by increasing the parabola angle
            foundFlag=true
            trajectoryRange=leftRange
            break
        end
    end
    --an angle exists by increasing the parabola angle, change search precision to 0.1 degree (decreasing)
    if(angleFlagLeft) then
        --reset all flags
        angleOffset=0
        rightRange=0
        for i=0,1, 0.1 do --precision: 0.1 degree
            angleOffset=i
            if(anglePotential-angleOffset<90)then
                rightRange, trajectoryHeight=trajectoryCalc(velocity, anglePotential-angleOffset, false, diagram, diagramHeight, scaleX, scaleY)
            end
            if(rightRange<=maxRange) then
                local leftError=math.abs(rightRange-maxRange)
                local rightError=math.abs(rightTemp-maxRange)
                if leftError>=rightError then
                    anglePotential=anglePotential+angleOffset
                    trajectoryAngle=anglePotential
                    trajectoryRange=leftRange
                    break
                else
                    anglePotential=anglePotential-angleOffset+0.1
                    trajectoryAngle=anglePotential
                    trajectoryRange=rightTemp
                    break
                end
            end
            if(i==0.1)then
                rightTemp=leftRange
            elseif(leftRange<leftTemp)then
                rightTemp=leftRange
            end
        end
    end
    return foundFlag, trajectoryAngle, trajectoryRange, trajectoryHeight
end

-- set initial text element
--each line can contain 30 characters
local consoleText = "Please enter 2 required values.\nPlease re-enter the two values\nafter each calculation.\nPress enter to input."
local consoleMsg = display.newText({
    text=consoleText,
    x = math.ceil(contentWidth/3),
    y = math.ceil(contentHeight-contentHeight/11),
    font = native.systemFont,
    fontSize = math.ceil(contentHeight/50),
    align = "center"
})



-- initialize diagram
local diagram = display.newGroup()
diagram.x=0
diagram.y=0

--Function to refresh diagram, use diagram = refreshDiagram(diagram) to refresh
function refreshDiagram(diagram)
    display.remove(diagram)
    diagram=nil
    return display.newGroup()
end
-- width and height of diagram
local diagramWidth=math.ceil(0.9*contentWidth)
local diagramHeight=diagramWidth
--set diagram line legend
local lineLegend = display.newText({
    text="Blue: no air drag (standard parabola)\nRed: with air drag",
    x = math.ceil(contentWidth*8/10),
    y= math.ceil(diagramHeight+contentHeight/4),
    fontSize=math.ceil(contentHeight/50)
})
-- diagram scale and parameters
local scaleX
local scaleY
local maxRange --maximum range  
local maxHeight --maximum height
local velocity
local angle
local angleAlt --another angle of parabola in Type 2
local a --parabola parameter
local aAlt
local b --parabola parameter 
local bAlt
local trajectoryRange --range of trajectory  (given velocity and angle)
local trajectoryRangeAlt 
local trajectoryHeight --height of trajectory in Type 2 (given velocity and range)
local trajectoryHeightAlt
local trajectoryAngle --angle of trajectory in Type 2
local trajectoryAngleAlt
-- Create button listener
local widget=require("widget")
local calcButton 
--Button listener: calculate button
function calcButtonEvent(event)
    if (event.phase=="ended") then
        -- refresh diagram
        diagram=refreshDiagram(diagram)
        diagram.x=10
        diagram.y=10
        --determine the type
        --Type 1: velocity and angle are given. There must be a parabola and a the trejectory
        --maxRange and maxHeight are provided by parabola
        if (velocityInputStatus == true and angleInputStatus == true and rangeInputStatus == false) then
            --check input data
            if velocityInput<=0 then
                consoleMsg.text="Velocity should be\nbigger than 0!"
                return
            end
            if (angleInput<=0 or angleInput>=90) then
                consoleMsg.text="Angle should be bigger\nthan 0 degrees and smaller\nthan 90 degrees!"
                return
            end
            --calculate and display parabola
            velocity, angle, maxRange, maxHeight, a, b, flag = parabolaCalc(velocityInput, angleInput, nil, 1)
            scaleX=diagramWidth/maxRange --scaling
            scaleY=diagramHeight/maxHeight
            parabolaPrint(a,b,maxRange,diagram, diagramHeight, scaleX, scaleY)
            trajectoryRange,trajectoryHeight=trajectoryCalc(velocity, angle, true, diagram, diagramHeight, scaleX, scaleY)
            consoleMsg.text="Velocity: "..velocity.." m/s\nAngle: "..angle.." degrees\nRange(no drag):\n"..maxRange.." m\nRange (with drag):\n"..trajectoryRange.." m"
        --Type 2: velocity and range are given. There could be a parabola and a trajectory
        --maxHeight should provided by trajectoryHeight (if any)
        elseif (velocityInputStatus == true and angleInputStatus == false and rangeInputStatus == true) then
            --check input data
            if velocityInput<=0 then
                consoleMsg.text="Velocity should be\nbigger than 0!"
                return
            end
            if rangeInput<=0 then
                consoleMsg.text="Range should be\nbigger than 0!"
                return
            end
            --estimation of angle using parabola
            velocity, angle, maxRange, maxHeight, a, b, flag = parabolaCalc(velocityInput, nil, rangeInput, 2)
            -- the function will return a value bigger than 45


            if (flag) then
                --calculate the other angle
                local angleAlt=90-angle
                local maxHeightAlt --max height of the other parabola
                
                local foundFlag=false
                local foundFlagAlt=false
                -- find trajectory angle based on parabola
                foundFlag, trajectoryAngle, trajectoryRange, trajectoryHeight=searchTrajectory(velocity, angle, maxRange)
                foundFlagAlt, trajectoryAngleAlt, trajectoryRangeAlt, trajectoryHeightAlt=searchTrajectory(velocity,angleAlt,maxRange)

                if(foundFlag and foundFlagAlt)then
                    --recalculate parabola
                    velocity, angle, maxRange, maxHeight, a, b, flag = parabolaCalc(velocityInput, nil, maxRange, 2)
                    velocity, angleAlt, maxRange, maxHeightAlt, aAlt, bAlt, flag = parabolaCalc(velocityInput, angleAlt, maxRange, 1)
                    
                    maxHeight=math.max(trajectoryHeight,trajectoryHeightAlt,maxHeight)
                    scaleX=diagramWidth/maxRange --scaling
                    scaleY=diagramHeight/maxHeight
                    parabolaPrint(a,b, maxRange,diagram, diagramHeight, scaleX, scaleY)
                    parabolaPrint(aAlt,bAlt, maxRange, diagram, diagramHeight, scaleX, scaleY)
                    --print trajectory
                    trajectoryRange,trajectoryHeight=trajectoryCalc(velocity, trajectoryAngle, true, diagram, diagramHeight, scaleX, scaleY)
                    trajectoryRangeAlt,trajectoryHeightAlt=trajectoryCalc(velocity, trajectoryAngleAlt, true, diagram, diagramHeight, scaleX, scaleY)
                    --display console message
                    consoleMsg.text="Velocity: "..velocity.." m/s\nAngle (no drag): "..angle.."\n"..angleAlt.." degrees\nAngle (with drag): "..trajectoryAngle.."\n"..trajectoryAngleAlt.." degrees\nRange:\n"..trajectoryRange.." m"
                elseif(foundFlag==true and foundFlagAlt==false)then
                    --recalculate parabola
                    velocity, angle, maxRange, maxHeight, a, b, flag = parabolaCalc(velocityInput, nil, maxRange, 2)
                    velocity, angleAlt, maxRange, maxHeightAlt, aAlt, bAlt, flag = parabolaCalc(velocityInput, angleAlt, maxRange, 1)
                    
                    maxHeight=math.max(trajectoryHeight,maxHeight)
                    scaleX=diagramWidth/maxRange --scaling
                    scaleY=diagramHeight/maxHeight
                    parabolaPrint(a,b, maxRange,diagram, diagramHeight, scaleX, scaleY)
                    parabolaPrint(aAlt,bAlt, maxRange, diagram, diagramHeight, scaleX, scaleY)
                    --print trajectory
                    trajectoryRange,trajectoryHeight=trajectoryCalc(velocity, trajectoryAngle, true, diagram, diagramHeight, scaleX, scaleY)
                    consoleMsg.text="Velocity: "..velocity.." m/s\nAngle (no drag): "..angle.."\n"..angleAlt.." degrees\nAngle (with drag): "..trajectoryAngle.." degrees\nRange:\n"..trajectoryRange.." m"
                elseif(foundFlag==false and foundFlagAlt==true)then
                   --recalculate parabola
                   velocity, angle, maxRange, maxHeight, a, b, flag = parabolaCalc(velocityInput, nil, maxRange, 2)
                   velocity, angleAlt, maxRange, maxHeightAlt, aAlt, bAlt, flag = parabolaCalc(velocityInput, angleAlt, maxRange, 1)
                   
                   maxHeight=math.max(trajectoryHeightAlt,maxHeight)
                   scaleX=diagramWidth/maxRange --scaling
                   scaleY=diagramHeight/maxHeight
                   parabolaPrint(a,b, maxRange,diagram, diagramHeight, scaleX, scaleY)
                   parabolaPrint(aAlt,bAlt, maxRange, diagram, diagramHeight, scaleX, scaleY)
                   --print trajectory
                   trajectoryRangeAlt,trajectoryHeightAlt=trajectoryCalc(velocity, trajectoryAngleAlt, true, diagram, diagramHeight, scaleX, scaleY)
                    --display console message
                    consoleMsg.text="Velocity: "..velocity.." m/s\nAngle (no drag): "..angle.."\n"..angleAlt.." degrees\nAngle (with drag): "..trajectoryAngleAlt.." degrees\nRange:\n"..trajectoryRange.." m"
                else
                    consoleMsg.text="Error: range (with drag) cannot\nbe calculated."
                    return
                end
            else
                consoleMsg.text="Error: range (no drag) cannot\nbe reached!"
                return
            end
        --Type 3: angle and range are given. There must be a parabola and a trajectory
        --maxHeight is provided by trajectory 
        elseif (velocityInputStatus == false and angleInputStatus == true and rangeInputStatus == true) then
            --check input data
            if (angleInput<=0 or angleInput>=90) then
                consoleMsg.text="Angle should be bigger\nthan 0 degrees and smaller\nthan 90 degrees!"
                return
            end
            if rangeInput<=0 then
                consoleMsg.text="Range should be\nbigger than 0!"
                return
            end
            --estimation of velocity using parabola
            velocity, angle, maxRange, maxHeight, a,b, flag = parabolaCalc(nil, angleInput, rangeInput, 3)
            --search velocity of trajectory
            local velocityTemp=0
            --search precision:100
            while(true) do
                velocityTemp=velocityTemp+100
                trajectoryRange,trajectoryHeight=trajectoryCalc(velocityTemp, angle, false, diagram, diagramHeight, scaleX, scaleY)
                
                if trajectoryRange>=rangeInput then
                    break
                end
            end
            --search precision:10, recover the temp
            velocityTemp=velocityTemp-200
            while(true) do
                velocityTemp=velocityTemp+10
                trajectoryRange,trajectoryHeight=trajectoryCalc(velocityTemp, angle, false, diagram, diagramHeight, scaleX, scaleY)
                
                if trajectoryRange>=rangeInput then
                    break
                end
            end
            --search precision：1， recover the temp
            velocityTemp=velocityTemp-20
            while(true) do
                velocityTemp=velocityTemp+1
                trajectoryRange,trajectoryHeight=trajectoryCalc(velocityTemp, angle, false, diagram, diagramHeight, scaleX, scaleY)
                
                if trajectoryRange>=rangeInput then
                    break
                end
            end
            --calculate scale
            scaleX=diagramWidth/trajectoryRange --scaling
            scaleY=diagramHeight/trajectoryHeight
            parabolaPrint(a,b,maxRange,diagram, diagramHeight, scaleX, scaleY)
            maxHeight=trajectoryHeight
            if(trajectoryRange>maxRange) then
                maxRange=trajectoryRange
            end
            --print trajectory
            trajectoryRange,trajectoryHeight=trajectoryCalc(velocityTemp, angle, true, diagram, diagramHeight,scaleX, scaleY)
            consoleMsg.text="Velocity (no drag): "..velocity.." m/s\nVelocity (with drag): "..velocityTemp.." m/s\nAngle: "..angle.." degrees\nRange:\n"..trajectoryRange.." m"
        else
            consoleMsg.text="Error: the number of\nentered data is not 2."
            return
        end
        --calculate unit value of coordinate axis
        local xAxisUnit=0.1
        while(true) do
            if(maxRange/xAxisUnit<=1) then
                xAxisUnit=xAxisUnit/10
                break
            else
                xAxisUnit=xAxisUnit*10
            end
        end
        local yAxisUnit=0.1
        while(true) do
            if(maxHeight/yAxisUnit<=1) then
                yAxisUnit=yAxisUnit/10
                break
            else
                yAxisUnit=yAxisUnit*10
            end
        end
        --calculate how many unit values should be displayed on axes
        local xUnits=math.ceil(maxRange/xAxisUnit)
        local yUnits=math.ceil(maxHeight/yAxisUnit)
        
        --add axis and unitss to the diagram
        for i=0, xAxisUnit*xUnits, xAxisUnit do
            diagram:insert(display.newText({
                text=i,
                x=i*scaleX,
                y=diagramHeight+math.floor(contentHeight/40),
                align="center",
                fontSize=math.floor(contentHeight/45)
            }))
            diagram:insert(display.newLine(i*scaleX,diagramHeight,i*scaleX,0))
        end
        for i=0, yAxisUnit*(yUnits-1), yAxisUnit do
            diagram:insert(display.newText({
                text=i,
                x=contentWidth/35,
                y=diagramHeight-i*scaleY,
                fontSize=math.floor(contentHeight/45)
            }))
            diagram:insert(display.newLine(0,diagramHeight-i*scaleY,contentWidth,diagramHeight-i*scaleY))
        end
        --add legends
        diagram:insert(display.newText({
            text="Range (m)",
            x=diagramWidth/2,
            y=diagramHeight+math.floor(contentHeight/25),
            fontSize=math.floor(contentHeight/45)
        }))
       
        diagram:insert(display.newText({
            text="H\ne\ni\ng\nh\nt\n(m)",
            x=0,
            y=diagramHeight+math.floor(contentHeight/25),
            fontSize=math.floor(contentHeight/45)
        }))
        --set status to 0
        angleInputStatus=false
        velocityInputStatus=false
        rangeInputStatus=false
    end
end
--create button
local button1 = widget.newButton(
    {
        x=math.ceil(contentWidth*7/9),
        y=math.ceil(contentHeight-contentHeight/14),
        id="calcButton",
        label="Calculate",
        labelColor={default={1,1,1}, over={1,1,1,0.5}},
        -- properties for a  rectangle button
        shape="roundedRect",
        width=math.ceil(0.275*contentWidth),
        height=math.ceil(0.1*contentHeight),
        cornerRadius=5,
        fillColor = { default={1,0,0,1}, over={0.54,0.24,0.18,1} },
        onEvent=calcButtonEvent,
    } 
)

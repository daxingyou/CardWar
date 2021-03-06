---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by zhengnan.
--- DateTime: 2019/5/7 14:17
---
local sqrt 	= math.sqrt
---@class Math3D
local Math3D = {}


-- xz平面坐标是否相等
---@param pos1 UnityEngine.Vector3
---@param pos2 UnityEngine.Vector3
function Math3D.Equal_XZ(pos1, pos2, maxDistanceDelta)
    pos2.y = pos1.y
    local delta = pos2 - pos1
    local sqrDelta = delta:SqrMagnitude()
    local sqrDistance = maxDistanceDelta * maxDistanceDelta
    if sqrDelta > sqrDistance then
        local magnitude = sqrt(sqrDelta)
        if magnitude > 1e-6 then
            return false
        else
            return true
        end
    end
    return true
    --return pos1.x == pos1.x and pos2.z == pos2.z
end

--是否到达知道点
---@param srcPos UnityEngine.Vector3
---@param dstPos UnityEngine.Vector3
---@param delta number
function Math3D.isArrived(srcPos, dstPos, delta)
    local distance = Vector3.Distance(srcPos, dstPos, delta)
    if distance < delta then
        return true
    else
        return false
    end
end

-- xz平面的朝向
---@param src UnityEngine.Transform
---@param dstPos UnityEngine.Vector3
function Math3D.ForwardPos(src, dstPos)
    local dstPos = Vector3.New(dstPos.x, src.position.y, dstPos.z)
    local dir = (src.position - dstPos).normalized
    src.forward = dir
end

-- xz平面的朝向
---@param src UnityEngine.Transform
---@param dstPos UnityEngine.Vector3
function Math3D.LookAt2DPos(src,dstPos,duration)
    local dstPos = Vector3.New(dstPos.x, src.position.y, dstPos.z)
    --src:LookAt(dstPos)
    if duration then
        return src:DOLookAt(dstPos,duration,DOTween_Enum.AxisConstraint.Y)
    else
        local dstPos = Vector3.New(dstPos.x, src.position.y, dstPos.z)
        src:LookAt(dstPos)
    end
end

-- xz平面的朝向
---@param src UnityEngine.Transform
---@param dst UnityEngine.Transform
function Math3D.LookAt2D(src,dst)
    local dstPos = Vector3.New(dst.position.x, src.position.y, dst.position.z)
    src:LookAt(dstPos)
end

--This function returns a point which is a projection from a point to a plane.
--点到面的投影点
---@param planeNormal Vector3
---@param planePoint Vector3
---@param point Vector3
function Math3D.ProjectPointOnPlane(planeNormal, planePoint, point)
    local distance;
    local translationVector;
    --First calculate the distance from the point to the plane:
    distance = Math3D.SignedDistancePlanePoint(planeNormal, planePoint, point);
    --Reverse the sign of the distance
    distance = distance * -1;
    --Get a translation vector
    translationVector = Math3D.SetVectorLength(planeNormal, distance);
    --Translate the point to form a projection
    return point + translationVector;
end

--带长度的向量
---@param vector Vector3
---@param size number
function Math3D.SetVectorLength(vector, size)
    --normalize the vector
    local vectorNormalized = Vector3.Normalize(vector);
    --scale the vector
    return vectorNormalized * size;
end

--点到面的投影距离
--Get the shortest distance between a point and a plane. The output is signed so it holds information
--as to which side of the plane normal the point is.
---@param planeNormal Vector3
---@param planePoint Vector3
---@param point Vector3
function Math3D.SignedDistancePlanePoint(planeNormal, planePoint, point)
    return Vector3.Dot(planeNormal, (point - planePoint));
end

--求XZ平面位移距离
---@param tagPos Vector3
---@param src UnityEngine.Transform
---@return Vector3
function Math3D.XZ_PlaneMove(tagPos, src)
    local tagPlane = Plane.New(Vector3.up, tagPos) -- XZ平面
    local yDotForward = Vector3.Dot(Vector3.up, src.transform.forward) --相机和垂直方向夹角
    local yDistance = Math3D.SignedDistancePlanePoint(-tagPlane.normal, tagPos, src.transform.position)
    local cam2TagPlaneDistance = yDistance / yDotForward
    local tagCurrPos = src.transform.position + src.transform.forward * cam2TagPlaneDistance
    local dir = tagPos - tagCurrPos
    return src.transform.position + dir
end


-- 获取目标点周围点
---@param center UnityEngine.Vector3
---@param radius number 半径
---@param num number
---@return AroundPoint
function Math3D.GetAroundPoints(center,radius,num)
    local angle = (360 / num) * (Mathf.PI / 180)
    local aroundPoints = {}
    for i = 1, num do
        local x = Mathf.Cos((i - 1) * angle) * radius
        local z = Mathf.Sin((i - 1) * angle) * radius
        table.insert(aroundPoints, {
            point = Vector3.New(center.x + x,center.y,center.z + z),
            owenerId = 0,
        })
    end
    return aroundPoints
end

-- 获取目标点周围点
---@param center UnityEngine.Vector3
---@param radius number 半径
---@param num number
---@return AroundPoint
function Math3D.GetAroundPoints(center,radius,num)
    local angle = (360 / num) * (Mathf.PI / 180)
    local aroundPoints = {}
    for i = 1, num do
        local x = Mathf.Cos((i - 1) * angle) * radius
        local z = Mathf.Sin((i - 1) * angle) * radius
        table.insert(aroundPoints, {
            point = Vector3.New(center.x + x,center.y,center.z + z),
            owenerId = 0,
        })
    end
    return aroundPoints
end


-- 获取目标点数组最近的点
---@param center UnityEngine.Vector3
---@param points table<number, AroundPoint>
---@return AroundPoint
function Math3D.GetAroundNearestPoint(center, points)
    local minDistance = Mathf.Infinity
    local point
    for i = 1, #points do
        local distance = Vector3.Distance(center, points[i].point)
        if distance < minDistance and points[i].owenerId == 0 then
            minDistance = distance
            point = points[i]
        end
    end
    return point
end

-- 获取目标点数组最近的点
---@param center UnityEngine.Vector3
---@param points table<number, UnityEngine.Vector3>
---@return UnityEngine.Vector3
function Math3D.GetNearestPoint(center, points)
    local minDistance = Mathf.Infinity
    local point
    for i = 1, #points do
        local distance = Vector3.Distance(center, points[i])
        if distance < minDistance then
            minDistance = distance
            point = points[i]
        end
    end
    return point
end

-- 获取目标点数组最远的点
---@param center UnityEngine.Vector3
---@param points table<number, AroundPoint>
---@return AroundPoint
function Math3D.GetFarestPoint(center,points)
    local maxDistance = 0
    local point
    for i = 1, #points do
        local distance = Vector3.Distance(center, points[i].point)
        if distance > maxDistance and points[i].owenerId == 0 then
            maxDistance = distance
            point = points[i]
        end
    end
    return point
end

---@param self UnityEngine.Transform
---@param tag UnityEngine.Transform
function Math3D.IsFront(self,tag)
    local dir = tag.position - self.position
    return Vector3.Dot(self.forward, dir.normalized) > 0
end

--以某点为中心,创建矩形
---@param center UnityEngine.Vector3
---@param width number
---@param height number
---@return UnityEngine.Rect
function Math3D.CreateRect(center, width, height)
    return Rect.New(
            center.x - width / 2,
            center.y - height / 2,
            width,height)
end

-- 获取目标点为圆形的园最近的交点
---@param src UnityEngine.Vector3
---@param tag UnityEngine.Vector3
---@param radius number
---@return UnityEngine.Vector3
function Math3D.GetCircleNearestPoint(src, tag, radius)
    local dir = src - tag
    local dst = dir.normalized * radius + tag
    return dst
end

-- 获取周围随机点
---@param center UnityEngine.Vector3
---@param radius number
---@return UnityEngine.Vector3
function Math3D.GetAroundRandomPoint(center, radius, from, to)
    from = from == nil and 0 or from
    to = to == nil and 360 or to
    local angle = math.random(from,to) * (Mathf.PI / 180)
    local x = Mathf.Cos(angle) * radius
    local z = Mathf.Sin(angle) * radius
    return Vector3.New(center.x + x,center.y,center.z + z)
end

-- 获取背后扇形区域N数量 angle角度内的点
---@param src UnityEngine.Transform
---@param angle number
---@param n number
---@param grid AStar.Grid
---@return table<number, UnityEngine.Vector3>
function Math3D.GetBehindPoints(src, angle, n, distance, grid)
    local orgDir = -src.forward
    local newVecs = {}
    if n == 1 then
        local newPos = src.position + orgDir * distance
        table.insert(newVecs, newPos)
    else
        local deltaAngle = angle / (n - 1)
        local startAngle = - angle / 2
        for i = 1, n do
            local newDir = Quaternion.Euler(0,startAngle + (i - 1) * deltaAngle,0) * orgDir
            table.insert(newVecs, src.position + newDir * distance)
        end
    end
    return newVecs
end

-- 获取某点为中心成矩形布局的 w * h 数量的点 - XZ轴
---@param start UnityEngine.Vector3
---@param rect UnityEngine.Rect
---@param r number
---@return table<number, UnityEngine.Vector3>
function Math3D.GetRectPoints(rect, start, r)
    local L = r * 2
    local list = {}
    for i = 1, rect.height do
        for j = 1, rect.width do
            local pt = start + Vector3.New(r + (j - 1) * L,0,r + (i - 1) * L)
            table.insert(list, pt)
        end
    end
    return list
end

-- 获取某点为中心成矩形布局的 w * h 数量的点 - XZ轴
---@param grid AStar.Grid
---@param start UnityEngine.Vector3
---@param rect UnityEngine.Rect
---@return table<number, UnityEngine.Vector3>
function Math3D.GetRectRandomPoints(grid, rect, start)
    local startNode = grid:NodeFromWorldPoint(start)
    local list = {}
    local idx = 1
    for i = 1, rect.height do
        for j = 1, rect.width do
            local node = grid:GetNode(startNode.gridX + j - 1, startNode.gridY + i - 1)
            if node.walkable and (node.gridX ~= rect.center.x and node.gridY ~= rect.center.y) then
                table.insert(list, node.worldPosition)
            end
            idx = idx + 1
        end
    end
    local randomList = {}
    local randoms = Tool.GetRandomArray(#list)
    for i = 1, #randoms do
        randomList[i] = list[randoms[i]]
    end
    return randomList
end

-- 获取某点为中心成矩形布局的 w * h 数量的点 - XZ轴
---@param grid AStar.Grid
---@param start UnityEngine.Vector3
---@param w number
---@param h number
---@return UnityEngine.Rect
function Math3D.GetNodeRect(grid, start, w, h)
    local startNode = grid:NodeFromWorldPoint(start)
    return Rect.New(startNode.gridX, startNode.gridY, w or 1, h or 1)
end

-- 获取向量的垂直向量
---@param vec3 UnityEngine.Vector3
---@param aixs UnityEngine.Vector3 轴
---@return UnityEngine.Vector3
function Math3D.GetVerticalVector3(vec3,aixs)
    local dir = Vector3.Cross(vec3, aixs)
    return dir.normalized
end

-- 是否在圆形范围内
---@param radius number
---@param tagPos UnityEngine.Vector3
---@param srcPos UnityEngine.Vector3
---@return boolean
function Math3D.IsInCircleRange(radius,srcPos,tagPos)
    local distance = Vector3.Distance(tagPos, srcPos)
    if distance <= radius then
        return true
    else
        return false
    end
end

-- 是否在扇形（锥形）范围内
---@param radius number
---@param angle number
---@param src UnityEngine.Transform
---@param tag UnityEngine.Transform
---@return boolean
function Math3D.IsInConeRange(radius,angle,src,tag)
    --local FdotTagPos = Vector3.Dot(src.forward, Vector3.Normalize(targetPos - src.position))
    local FdotTag = Mathf.Abs(Vector3.Dot(src.forward, Vector3.Normalize(tag.position - src.position)))
    local distance = Vector3.Distance(src.position, tag.position)
    if distance <= radius and FdotTag <= Mathf.Cos((angle / 2) * Mathf.Deg2Rad) then
        return true
    else
        return false
    end
end

-- 是否在矩形范围内
---@param width number
---@param length number
---@param src UnityEngine.Transform
---@param tag UnityEngine.Transform
---@return boolean
function Math3D.IsInRectRange(width,length,src,tag)
    local deltaA = tag.transform.position - src.transform.position
    local forwardDotA = Vector3.Dot(src.transform.forward, deltaA)
    if forwardDotA > 0 and forwardDotA <= length then
        if Mathf.Abs(Vector3.Dot(src.transform.right, deltaA)) < width/2 then
            return true
        end
    end
    return false
end


-- 是否在矩形范围内
---@param num number
---@param gap number
---@param src UnityEngine.Transform
---@param distance number
---@return table<number, UnityEngine.Vector3>
function Math3D.GetForwardPos(src,num,gap,distance)
    local dir = src.right
    local forward = src.forward
    local width = num * gap
    local leftPos = src.position + -src.right * (width / 2)
    local points = {}
    for i = 1, num do
        local pos = leftPos + dir * (i - 1) * gap + forward * distance
        table.insert(points, pos)
    end
    return points
end
return Math3D
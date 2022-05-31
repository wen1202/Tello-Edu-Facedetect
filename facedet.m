%%Copyright wen 2022
%%
clear all;
clc;%日常清理
mytello=ryze();
cameraTello=camera(mytello);%開啟相機
preview(cameraTello);
takeoff(mytello);%起飛

pause(1);
faceDetector = vision.CascadeObjectDetector;
%faceDetector.ClassificationModel = 'FrontalFaceLBP';
%faceDetector.MinSize = [30 30];
%faceDetector.MergeThreshold = 10;
moveup(mytello,'Distance',0.5);%往上飛0.5m 

minoffset=20; %位移
count=0;
while(1)
    img=snapshot(cameraTello);
    followface(faceDetector,mytello,img,20);
    count=count+1;
    if  count>30
        break;
    end
    pause(0.5);
end
land(mytello);
%%
function followface(facedetect,ryzeObj,image,offset)
    rows=size(image,1);%解析度 圖片寬 y
    cols=size(image,2);%圖片長 x
    bbox=facedetect(image);%人臉辨識返回數組[x,y,weidth,heigth]    
    
    if ~isempty(bbox)
    face_count = size(bbox,1);
    closest = false;
    mn = -Inf;
    for i = 1:face_count
        face = bbox(i,:);
        w = face(3);
        h = face(4);
        area = w*h;
        if area > mn
        mn = area;
        closest = i;
    end
    end
    faces = insertObjectAnnotation(image,'Rectangle',bbox(closest,:),'Face','Color','r','LineWidth',8);
    imshow(faces)
    drawnow
    XCenter =  bbox(1)+bbox(3);%人臉中心 X座標
    YCenter =  bbox(2)+bbox(4);%人臉中心 Y座標
    
    rowOffset = (rows/2) - XCenter;%人臉中心和圖片中心的差距->飛機要位移的距離
    colOffset = (cols/2) - YCenter;
    
    if(colOffset < -offset && rowOffset >=-offset && rowOffset <=offset)%如果人臉在無人機右邊，無人機往右飛
        disp("Moving the drone right");
        moveright(ryzeObj,'Distance',0.2);
    elseif(colOffset  > offset && rowOffset >=-offset && rowOffset <=offset)%如果人臉在無人機左邊，無人機往左飛
        disp("Moving the drone left");
        moveleft(ryzeObj,'Distance',0.2);
    elseif(rowOffset > offset && colOffset >=-offset && colOffset <=offset)%如果人臉在無人機上面，無人機往上飛
        disp("Moving the drone up",'Distance',0.2);
        moveup(ryzeObj);
    elseif(rowOffset < -offset && colOffset >=-offset && colOffset <=offset)%如果人臉在無人機下面，無人機往下飛
        disp("Moving the drone down",'Distance',0.2);
        movedown(ryzeObj);
    else
        disp("Hovering");
    end
    end
end
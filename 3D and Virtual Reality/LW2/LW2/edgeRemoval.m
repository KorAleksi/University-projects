function edgeRemoval( h )
% Gets the handle h to a surf object, removes the stretched triangles causing
% artifacts on the edges of objects


face_norm =h.FaceNormals;
s = size(face_norm);
for y=1:s(1)
    for x=1:s(2)
       normal =  face_norm(y,x,:);
       normal = abs(normal);
       if normal(3) < normal(1) || normal(3) < normal(2)
          h.CData(y,x) = NaN; 
       end         
    end
end
end


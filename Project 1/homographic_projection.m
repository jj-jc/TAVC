function [projected_I] = homographic_projection(H, I, projected_I)
for x=1:size(I,1)*2
    for y=1:size(I,2)*2
        pos = [y/2,x/2,1]';
        pos_t = H*pos;
        pos_t = pos_t/pos_t(3,1);
        pos_t(1,1) = round(pos_t(1,1)) + 1000;
        pos_t(2,1) = round(pos_t(2,1)) + 1000;
%         if isequal(projected_I(pos_t(2,1),pos_t(1,1) , :),[0,0,0])
           projected_I(pos_t(2,1),pos_t(1,1) , :)=I(round(x/2),round(y/2),:);
%         else
%             projected_I(pos_t(2,1),pos_t(1,1) , :)=(projected_I(pos_t(2,1),pos_t(1,1) , :)+I(round(x/2),round(y/2),:))/2;
%         end
    end
end

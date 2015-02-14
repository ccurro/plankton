require 'nn'
require 'cunn'
require 'cutorch'
require 'image'
require('randTransform.lua')

--fSize = {1,16,16,32}
fSize = {1,256,256,256,512,512,600,692,792}
featuresOut = fSize[8]*2*2
hiddenNodes = {512,256}
--hiddenNodes = {64,32}

features = nn.Sequential()
features:add(nn.MsSpatialConvolutionMM(fSize[1],fSize[2],2,2,2,2)) -- (120 - 2 + 2)/2 = 60
features:add(nn.Threshold(0,1e-6))
features:add(nn.ReLU())
features:add(nn.SpatialMaxPooling(2,2)) -- 30
features:add(nn.MsSpatialConvolutionMM(fSize[2],fSize[3],3,3)) -- 28
features:add(nn.Threshold(0,1e-6))
features:add(nn.ReLU())
features:add(nn.SpatialMaxPooling(2,2)) -- 14
features:add(nn.MsSpatialConvolutionMM(fSize[3],fSize[4],4,4)) -- 11 
features:add(nn.Threshold(0,1e-6))
features:add(nn.ReLU())
features:add(nn.MsSpatialConvolutionMM(fSize[4],fSize[5],4,4)) -- 8
features:add(nn.Threshold(0,1e-6))
features:add(nn.ReLU())
features:add(nn.MsSpatialConvolutionMM(fSize[5],fSize[6],3,3)) -- 6
features:add(nn.Threshold(0,1e-6))
features:add(nn.ReLU())
features:add(nn.MsSpatialConvolutionMM(fSize[6],fSize[7],3,3)) -- 4
features:add(nn.ReLU())
features:add(nn.MsSpatialConvolutionMM(fSize[7],fSize[8],3,3)) -- 2
features:add(nn.View(featuresOut))
features:cuda()

dgraph = nn.Sequential()
dgraph:add(nn.Linear(featuresOut,featuresOut))
dgraph:add(nn.Dropout(0.5))
dgraph:add(nn.ReLU())
dgraph:add(nn.Linear(featuresOut,121))

mdl = nn.Sequential()
mdl:add(features)
mdl:add(dgraph)
mdl:add(nn.LogSoftMax())
mdl:cuda()

--output = torch.CudaTensor(10):fill(1)
--
--criterion = nn.ClassNLLCriterion()
--criterion:cuda()
--
--for i=1,30 do
--  local currentError = 0
--  input = torch.randn(1,1,512,512)
--  input = randomTransform(input[1][1],10):cuda()
--  oHat = mdl:forward(input)
--  currentError = currentError + criterion:forward(oHat,output)
--  mdl:zeroGradParameters()
--  mdl:backward(input,criterion:backward(mdl.output,output))
--  mdl:updateParameters(6e-1)
--  if i % 10 == 0 then
--    print('Batch:',i,'Error:',currentError/58)
--  end
--  collectgarbage()
--end
--
--print(torch.pow(10,oHat:float()))

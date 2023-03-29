classdef BUAparameters_test < matlab.unittest.TestCase
    %BUAparameters_test < matlab.unittest.TestCase
    %
    % clear;close all;clc;testCase = BUAparameters_test; res = testCase.run;disp(res);
    %
    %
    % See also
    %

    properties
        basedir
        homedir
        resdir
    end

    methods (Test)
        function test1(testCase)
            % clear;close all;clc; testCase = BUAparameters_test; disp(testCase.run('test1'));
            %
            % *Best practise* ... run the following command and then evaluate
            % secion by section:
            %
            % testCase = BUAparameters_test;

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.TestSuite;
            import matlab.unittest.fixtures.WorkingFolderFixture;

            [testCase.basedir,testCase.homedir,~,~,testCase.resdir] = setup();


            load(fullfile(testCase.resdir, 'chanSpec_eegpow_lfppow_act_actdelta.mat')); %chanSpec

            chanSpec = changepathplatform(chanSpec,testCase.basedir);


            TFact       = chanSpec.isact;
            TFactdelta  = chanSpec.isactdelta;
            TFchan_eeg  = chanSpec.ischan_EEG;
            TFmat_ME1_LFP = chanSpec.ismatvalid(chanSpec.ischan_ME1_LFP);

            chanSpecB = chanSpec.choose(...
                (TFact | TFactdelta) & ...
                chanSpec.ismatvalid(chanSpec.ischan_BZ) &...
                (TFchan_eeg | TFmat_ME1_LFP));

            tf = chanSpecB.ischan_ME1_LFP;

            % temporary folder

            f = WorkingFolderFixture('PreservingOnFailure',true);
            testCase.applyFixture(f);

            obj = BUAparameters(chanSpecB,pwd,testCase.basedir);
            disp(obj)


            %% Visual inspection of peak detection

            obj.inspectThresholdOne(1,1)

            obj.inspectThresholdMany(tf)


            %% Spike removal window One

            obj = obj.averagewaveformOne(1,1);

            dir('*.mat')

            % the modifcation made previously (line 67) should be reflected
            % because of the updated properties of obj
            obj = obj.averagewaveformOne(1,1);



            %% Spike removal window Some and All
            close all;clear obj

            obj = BUAparameters(chanSpecB,pwd,testCase.basedir);

            obj = obj.averagewaveformMany(tf);
            dir('*.mat')

            % previous changes should be reflected by updated Tparams of
            % obj
            obj = obj.averagewaveformMany(tf); %OK

            % constructor should read the saved .mat file
            % confrim that previous changes are maintained
            obj2 = BUAparameters(chanSpecB,pwd,testCase.basedir);
            disp(obj2)
            disp(obj2.Tparams(:,2:5))

            obj2 = obj2.averagewaveformMany; %OK

            obj2 = obj2.averagewaveformRest; %OK
            disp(obj2.Tparams)

            %% get parameters for getBUA
            chanSpecEEG = chanSpecB.choose(tf);
            W = chanSpecEEG.constructChan(1,1);
            thre = obj2.getThre(W,1,1);
            disp(thre)

            spikeWin = obj2.getSpikeWin(1,1);
            disp(spikeWin)

            % SDx order loading
            obj2.SDx = 4;
            obj2.order = 4;
            obj2.saveT;
            obj3 = BUAparameters(chanSpecB,pwd,testCase.basedir);

            testCase.verifyEqual(obj3.Tparams.Properties.UserData.SDx,4);
            testCase.verifyEqual(obj3.Tparams.Properties.UserData.order,4);

            %% Batch assignment

            obj.averagewaveformBatch(tf)

        end

    end

end

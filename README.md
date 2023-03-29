# Chan_Spike2
MATLAB tool to analyse neuroscience data derived from CED's Spike2 acquisition software

This repo contains a bunch of class def files and functions. Many of them are closely related to or required for the `Chan` class family. They offer many methods and functions for the analysis of Spike2 format electrophysiological data.



## Classes

### WaveformChan, EventChan, MarkerChan classes

+ There are subclasses of `Chan` superclass.
+ Classes that are designed to work with `*.mat` files containing electrophysiological data in structure format that are exported from Spike2.
+ They automatically convert stored data format to more accessible format; `int16` to `double` (`WaveformChan`), `sparse double` to `full double` (`EventChan`), time stamps to binned data (`MarkerChan`) .
+ They allow easy access to many useful functions (methods) with simple syntaxes to construct an object (see below).

```matlab
w = WaveformChan(S1) % construction of WaveformChan object w from structure S1
w.plot % visual inspection of waveform data
```

- For waveform data (continous data), eg. EEG, LFP, unit recording


```matlab
e = EventChan(S2) % construction of EventChan object e from structure S2
e.plot % visual inspection of event data
```

- For event data, eg. spike, stim
- 

```matlab
m = MarkerChan(S3,S1)
% construction of MarkerChan object m from structure S3
% with reference to waveform channel S1
m.plot % visual inspection of marker data
```

- For event data. You can assign (up to 4 codes per event) `MarkerCodes` to individual events for grouping and with `MarkerFilter` you can decide whether to include or hide specific subset of events. This class mimicks the Marker channel type of Spike2.

- `WaveMarkChan` class is also available, although it is still under development and many methods won't work properly.
    - Subclass of `MarkerChan` class.
    - Hold wavemark (spike waveform) data in `Trace` property
    - `plot` method can show spikes as wavemarks (spike waveforms) or as events

#### See also

```
WaveformChan_test, EventChan_test, MarkerChan_test, Record
```



### Record class

+ When the `time` vector of `Chan` class objects (`WaveformChan`,`EventChan`, `MarkerChan`) are common, you can combine them in a `Record` object. Thus you can reproduce a Spike2 recording file (`*.smr` file).
+ After editing a `Record` object, you can export the data into a new Spike2 `*.smr` file by the `writesmr` method. Spike2 offers a better browsing experience than MATLAB.

``` matlab
w1 = WaveformChan(S1); % S1 and S2 are a structure exported by Spike2
e1 = EvenChan(S2);

rec = record({w1,e1}); % construction of Record object
rec.plot % visual inspection of data

rec.writesmr('foo.smr') % write into a new Spike2 (32 bit) .smr file
```

- `RecordA` ("A" for asynchronous) is similar, but accepts channels (`Chan` objects) that do not share the time vector.



| Class | `Record`                                        | `RecordA`                                                    |
| ----- | ----------------------------------------------- | ------------------------------------------------------------ |
| Time  | Identical, shared in`obj.Time`                  | No `Time` property. Channels can have non-matching time vectors (`Start`, `SRate`, and `Length` can be different). |
| Pros  | Easy to handle data.                            | Flexible. Can store various data in on object.               |
| Cons  | Cannot handle data with different time vectors. | You need to consider time vectors for channels individually. Some methods are not supported. |



#### See also

```
Record_test, RecordA, WaveformChan, EventChan, MarkerChan
```





### LTSburst class

+ Interspike interval analysis for detecting low-threshold calcium spike (LTS) burst

```matlab
e1 = EvenChan(S2); % S2 are a structure exported by Spike2

bst = LTSburst(e1); % construction with default parameters
% bst.PreburstSilence_ms = 100,
% bst.FirstISImax_ms = 5,
% bst.LastISImax_ms = 10
bst.plotISIordinal; % plot ISI ordinal of LTS bursts

Mbst = bst.constructBurstAsMarker; % construct a MarkerChan object for burst onset(01) / offset(00)
```



#### See also

```
LTSburst_test
```



### ChanSpecifier class

+ Stores meta-information about `*.mat` files in a specified folder
+ Helps you to choose specific subset of data by returning a logical vector for files and channels that satisfy a given condition and by boolean operation of logical vectors.


```matlab
chanSpec = ChanSpecifier(folderpath); % construction of a ChanSpecifier object

TF1 = chanSpec.ischanvalid('meanfiringrate', @(x) x > 0.8) % select channels with meanfiring rate larger than 0.8

TF2 = chanSpec.ischantitlematched('LTS'); % select channels whose ChanTitle include 'LTS'

chanSpec2 = chanSpec.choose(TF1 & TF2); % get subset of channels that satisfy the above two conditions

rec = chanSpec2.constructRecord(3); % construct a Record object by loading data of the third  mat file in chanSpec2

rec.plot; % visual inspection of data


```



#### See also

```
ChanSpecifier_test, ChanSpecifier_thalamus
```





### BUApapameters class

* Store and access parameters for background unit activity (BUA) extraction.
* Helps you to visually inspect the effect of spike removal with a certain time window.
* Closely related to `getBUA` method of `WaveformChan` class.

```matlab
buaparams = BUAparameters(chanSpec,paramdir,basedir)

% chanSpec   a ChanSpecifier object
% paramdir   data will be stored here
% basedir    to be used to create full path
```



#### See also

```
ChanSpecifier
```



## Functions

More # in Rating means they are more recommended.

| Function                         | Description                                                  | Rating | See also                                                     |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------------------------------------------------------------ |
| `createBUA2`                     | Replace large spikes with randomly chosen background for BUA extraction. Originally written by Izhar Bar-gad | ##     | `createBUA` by Izhar Bar-gad                                 |
| `crossthreshold`                 | **Find a point where a waveform data crosses a threshold**   | #####  | `crossthreshold_demo`, `bwconncomp`                          |
| `findEpochsByEnvelope`           | Return subset of data filtered whose envelope satisfies criteria. Developed for spindle oscillations. | ##     | `crossthreshold`                                             |
| `getSDF`                         | **Convert spike trains to spike density function (SDF) with a convolution of Gaussian filter** | #####  | `conv`,`normpdf`                                             |
| `K_checkmerge`                   | Check the status of 3 way merge of `*.smr`, `*.xlsx`,  and `*.mat` files. Returns which files need to be updated or deleted. This function is very similar to `K_getupdatedmerge` but this is specifically designed for the special work flow for `*.smr`, `*_info.xlsx` and `*_m.mat` files. | #      | `K_checkmerge_test`, `K_getupdatedmerge` (a generic version of the function) |
| `K_ECDFforRayleigh`              | **ECDF-based correction of nonuniformity of data for Rayleigh's test** | #####  | `circ_rtest`, `ecdf`, `K_PhaseHist`                          |
| `K_extractExcelDataForSpike2`    | Read the `kjx data summary.xlsx` file in `excelpath`, take out relevant information, and save them into `*.xlsx` files (`*.csv` doesn't support export from a cell array) in a predetermined folder `destfolder`. Those data can be later imported into `*.mat` recording data files exported from Spike2 with `K_importExcelData2structSpike2`. | #      | `K_extractExcelDataForSpike2_test`, `K_extractExcelDataForSpike2_fixture`, `K_importExcelData2structSpike2`, `K_importXYZ_csv2masterxlsx` |
| `K_filtGaussianY`                | apply a gaussian filter                                      | ##     | `K_filtGaussianY_sec`                                        |
| `K_filtGaussianY_sec`            | apply a gaussian filter with parameters in seconds           | ##     | `K_filtGaussianY`                                            |
| `K_folder_mat2record`            | Converts Spike2 struct-containing `*.mat` files in the `srcdir` folder into Record objects in the destdir | #      | `Record`                                                     |
| `K_folder_mat2sparse`            | This function works on `*.mat` files in the `srcdir` folder and do a lot of jobs including conversion of event data into sparse double | #      |                                                              |
| `K_getupdated`                   | Compare and check the file status of `srcdir` and `destdir`. Returns which files need to be updated or deleted . | #      | `K_getupdatedmerge`, `K_getupdatedf`                         |
| `K_getupdatedf`                  | A wrapper of `K_getupdated` and `K_getupdatedmerge`. In addition to return a structure `S`, this will save text files that contains the name of files that need to be handled in a specified way (add, remove, or update). The text files can be used by the Spike2 script, `ExportAsMat.s2s`, via `FileOpen()` and `Read()` funcitons. | #      | `K_getupdated`, `K_getupdatedmerge`, `ExportAsMat.s2s`       |
| `K_getupdatedmerge`              | Check the file status of files in 3 folders, `src1dir`, `src2dir`, and `destdir`. Returns which files need to be updated or deleted. | #      | `K_getupdated`, `K_getupdatedf`, `K_checkmerge` (a purpose-specific form) |
| `K_importExcelData2structSpike2` | Imports data from `*_info.xlsx` files and merge them with `*_sp.mat` files and save as `*_m.mat` files. | #      | `K_importExcelData2structSpike2_test`, `K_extractExcelDataForSpike2` |
| `K_importXYZ_csv2masterxlsx`     | Imports X, Y, and Z coordinates from `*.csv` file (prepared by extract.py written by Dr Takuma Tanaka) and insert the values to the specified cells in Excel file excelpath. | #      | `K_importXYZ_csv2masterxlsx_test`, `K_importXYZ_csv2masterxlsx_fixture`, `extract.py` |
| `K_isstable`                     | isstable(b,a) returns a logical output, flag, equal to true if the filter specified by numerator coefficients, b, and denominator coefficients, a, is a stable filter. | #      | built-in `isstable`                                          |
| `K_pathAbs2Rel`                  | Converts an absolute path targetpath into relative path in relation to a folder at targetpath | ##     | `K_pathRel2Abs`                                              |
| `K_pathRel2Abs`                  | Converts an absolute path targetpath into relative path in relation to a folder at targetpath | ##     | `K_pathAbs2Rel`                                              |
| `K_PhaseHist`                    | **Phase histogram creation for the analysis of phase coupling of spiking activity of a neurons to ongoing ECoG/LFP.** | #####  | `K_PhaseWave`                                                |
| `K_PhaseHist_histlabel`          | Adding text label to phase histogram                         | ##     |                                                              |
| `K_PhaseWave`                    | **Phase-averaged waveform. For the analysis of phase coupling of LFP/BUA to the reference ECoG/LFP/BUA. ** | #####  | `K_PhaseHist`                                                |
| `K_plotCircPhaseHist_group_S`    | A circular plotting function for phase coupling of a group of neurons. Takes structure output of K_PhaseHist as input. | ###    | `K_PhaseHist`                                                |
| `K_plotCircPhaseHist_group`      | A circular plotting function for phase coupling of a group of neurons. | ###    | `K_PhaseHist`                                                |
| `K_plotCircPhaseHist_one_S`      | A circular plotting function for phase coupling of a single neuron.  Takes structure output of K_PhaseHist as input. | ###    | `K_PhaseHist`                                                |
| `K_plotCircPhaseHist_one`        | A circular plotting function for phase coupling of a single neuron. | ###    | `K_PhaseHist`                                                |
| `K_plotCircPhaseWave_group`      | A circular plotting function for phase coupling of LFP or BUA (group data). | ###    | `K_PhaseWave`                                                |
| `K_plotCircPhaseWave_one`        | A circular plotting function for phase coupling of LFP or BUA. | ###    | `K_PhaseWave`                                                |
| `K_plotColorPhaseHist`           | A heatmap plotting function for phase coupling of neurons.   | ###    | `K_PhaseHist`                                                |
| `K_plotLinearPhaseFrame`         | A plotting function for preparing frames for a linear phase histogram. | ###    | `K_PhaseHist`                                                |
| `K_plotLinearPhaseHist_S`        | A plotting function for a linear phase histogram of phase coupling of a group of neurons. Takes structure output of K_PhaseHist as input | ###    | `K_PhaseHist`                                                |
| `K_plotLinearPhaseHist`          | A plotting function for a linear phase histogram of phase coupling of a group of neurons. | ###    | `K_PhaseHist`                                                |
| `K_plotLinearPhaseWave`          | A plotting function for relationship between phase and LFP/BUA amplitude. | ###    | `K_PhaseWave`                                                |
| `K_PSTHcorr`                     | **PSTH and cross- or auto- correlogram drawing.**            | #####  |                                                              |
| `K_SONAlignAndBin`               | Directly read Spike2 .smr file and bin the data using `sigTOOL` | #      | `timestamps2binned`                                          |
| `methodsall`                     | Return all the methods of a class/object                     | ###    | `methods`, `methodsalltable`                                 |
| `methodsalltable`                | Return all the methods of a class/object as a table          | ###    | `methods`,  `methodsall`                                     |
| `normalizedfreq`                 | Return normalized frequency required for filter designing    | ###    | `butter`                                                     |
| `propertiesall`                  | Return all the properties of a class/object                  | ##     | `properties`, `propertiesalltable`                           |
| `propertiesalltable`             | Return all the properties of a class/object as a table       | ##     | `properties`, `propertiesall`                                |
| `smr2rec`                        | Converts specific channels in a Spike2 `*.smr` file to a `Record` object | ###    | `Record`, `K_SONAlignAndBin`                                 |
| `timestamps2binned`              | **Converts time stamps of events to a binned logical vector** | #####  | `K_SONAlignAndBin`                                           |
| `textforpwelch`                  | Place a text to power spectra for showing parameters         |        | `pwelch`,`text`                                              |
| `verticalScatPlot`               | **Vertical scatter plot for visualizing data distribution. Accepts data vector and a grouping variable** | #####  | `verticalScatPlot2`, `compareXG`, `compare2`, `getNforG`, `barXG` |
| `verticalScatPlot2`              | **Vertical scatter plot for visualizing distribution of two groups of data.** | #####  | `verticalScatPlot2`, `compareXG`, `compare2`                 |
| `xticklabeltidy`                 | **Tidy up XTickLabel of an axes object by controlling the number of digits to show.** | #####  | `yticklabeltidy`                                             |
| `yticklabeltidy`                 | **Tidy up YTickLabel of an axes object by controlling the number of digits to show.** | #####  | `xticklabeltidy`                                             |





# Contacts



Dr. Kouichi C. Nakamura

Brain Network Dynamics Unit,

University of Oxford,

Mansfield Road,

Oxford, Oxfordshire OX1 3TH, UK

kouichi.c.nakamura@gmail.com

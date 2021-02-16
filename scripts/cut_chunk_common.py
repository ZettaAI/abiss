from cloudvolume import CloudVolume
import chunk_utils as cu
import numpy
import os


def load_data(url, **kwargs):
    print("cloud volume url: ", url)

    return CloudVolume(url, **kwargs)
    #return CloudVolumeGSUtil(url, fill_missing=True)

def load_gt_data(url, mip=0):
    print("cloud volume url: ", url)
    print("mip level: ", mip)

    return CloudVolume(url, fill_missing=True, bounded=False, mip=mip)

def save_raw_data(fn,data, data_type):
    f = numpy.memmap(fn, dtype=data_type, mode='w+', order='F', shape=data.shape)
    f[:] = data[:]
    del f

def pad_boundary(boundary_flags):
    pad = [[0,0],[0,0],[0,0]]
    for i in range(3):
        if boundary_flags[i] == 1:
            pad[i][0] = 1
        if boundary_flags[i+3] == 1:
            pad[i][1] = 1
    return list(pad)

def pad_data(data, boundary_flags):
    pad = pad_boundary(boundary_flags)
    if len(data.shape) == 3:
        return numpy.lib.pad(data, pad, 'constant', constant_values=0)
    elif len(data.shape) == 4:
        return numpy.lib.pad(data, pad+[[0,0]], 'constant', constant_values=0)
    else:
        raise RuntimeError("encountered array of dimension " + str(len(data.shape)))

def cut_data(data, start_coord, end_coord, boundary_flags):
    bb = tuple(slice(start_coord[i], end_coord[i]) for i in range(3))
    if data.shape[3] == 1:
        return pad_data(data[bb], boundary_flags)
    elif data.shape[3] == 3:
        return pad_data(data[bb+(slice(0,3),)], boundary_flags)
    elif data.shape[3] == 4: #0-2 affinity, 3 myelin
        global_param = cu.read_inputs(os.environ['PARAM_JSON'])
        th = global_param.get('MYELIN_THRESHOLD', 0.3)
        print("threshold myelin mask at {}".format(th))
        cutout = data[bb+(slice(0,4),)]
        affinity = cutout[:,:,:,0:3]
        myelin = cutout[:,:,:,3]
        mask = myelin > th
        for i in range(3):
            tmp = affinity[:,:,:,i]
            tmp[mask] = 0
            #affinity[:,:,:,i] = numpy.multiply(affinity[:,:,:,i]*(1-myelin))
        return pad_data(affinity, boundary_flags)

    else:
        raise RuntimeError("encountered array of dimension " + str(len(data.shape)))



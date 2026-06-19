import sys, traceback
sys.path.append('.')
import keras
import tensorflow as tf

# Patch BatchNormalization
_orig_bn = keras.layers.BatchNormalization.from_config.__func__

@classmethod
def patched_bn(cls, config):
    config.pop('renorm', None)
    config.pop('renorm_clipping', None)
    config.pop('renorm_momentum', None)
    return _orig_bn(cls, config)

keras.layers.BatchNormalization.from_config = patched_bn

# Patch RandomFlip
_orig_rf = keras.layers.RandomFlip.from_config.__func__

@classmethod
def patched_rf(cls, config):
    config.pop('data_format', None)
    return _orig_rf(cls, config)

keras.layers.RandomFlip.from_config = patched_rf

# Register TrueDivide as a custom layer (it's just element-wise division)
@keras.saving.register_keras_serializable(package="Custom")
class TrueDivide(keras.layers.Layer):
    def call(self, inputs):
        return inputs[0] / inputs[1]
    
    def get_config(self):
        return super().get_config()

# Also register with keras custom object scope
import keras.utils
keras.utils.get_custom_objects()['TrueDivide'] = TrueDivide

# Register Subtract too, just in case
@keras.saving.register_keras_serializable(package="Custom")
class Subtract(keras.layers.Layer):
    def call(self, inputs):
        return inputs[0] - inputs[1]
    def get_config(self):
        return super().get_config()

keras.utils.get_custom_objects()['Subtract'] = Subtract

print("=== Trying .h5 model with TrueDivide shim ===")
try:
    m = tf.keras.models.load_model('ml_models/plant_disease_model.h5', compile=False)
    print("SUCCESS! H5 MODEL LOADED")
    print("Input:", m.input_shape)
    print("Output:", m.output_shape)
except Exception as e:
    print("H5 FAILED:", e)
    traceback.print_exc()

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import uniffi.mopro.GenerateProofResult
import uniffi.mopro.generateProof2
import uniffi.mopro.initializeMopro
import uniffi.mopro.verifyProof2
import android.content.Context
import androidx.compose.ui.platform.LocalContext
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

fun loadJsonFromAssets(context: Context, fileName: String): Map<String, List<String>> {
    val jsonString = context.assets.open(fileName).bufferedReader().use { it.readText() }
    val gson = Gson()
    val type = object : TypeToken<Map<String, List<String>>>() {}.type
    return gson.fromJson(jsonString, type)
}

@Composable
fun BenchmarkComponent() {
    var initTime by remember { mutableStateOf("init time:") }
    var provingTime by remember { mutableStateOf("proving time:") }
    var verifyingTime by remember { mutableStateOf("verifying time: ") }
    var valid by remember { mutableStateOf("valid:") }
    var proofSize by remember { mutableStateOf("proof size:") }
    var res by remember {
        mutableStateOf<GenerateProofResult>(
            GenerateProofResult(proof = ByteArray(size = 0), inputs = ByteArray(size = 0))
        )
    }

    val inputs = loadJsonFromAssets(LocalContext.current, "eddsa_input.json")
    Box(modifier = Modifier.fillMaxSize().padding(16.dp), contentAlignment = Alignment.Center) {
        Button(
            onClick = {
                Thread(
                    Runnable {
                        val startTime = System.currentTimeMillis()
                        initializeMopro()
                        val endTime = System.currentTimeMillis()
                        initTime =
                            "init time: " +
                                    (endTime - startTime).toString() +
                                    " ms"
                    }
                )
                    .start()
            },
            modifier = Modifier.padding(bottom = 80.dp)
        ) { Text(text = "init") }
        Button(
            onClick = {
                Thread(
                    Runnable {
                        val startTime = System.currentTimeMillis()
                        res = generateProof2(inputs)
                        val endTime = System.currentTimeMillis()
                        provingTime =
                            "proving time: " +
                                    (endTime - startTime).toString() +
                                    " ms"
                        proofSize = "proof size: " + res.proof.size.toString() + " bytes"
                    }
                )
                    .start()
            },
            modifier = Modifier.padding(top = 20.dp)
        ) { Text(text = "generate proof") }
        Button(
            onClick = {
                val startTime = System.currentTimeMillis()
                valid = "valid: " + verifyProof2(res.proof, res.inputs).toString()
                val endTime = System.currentTimeMillis()
                verifyingTime = "verifying time: " + (endTime - startTime).toString() + " ms"
            },
            modifier = Modifier.padding(top = 120.dp)
        ) { Text(text = "verify proof") }
        Text(
            text = "Mopro Benchmark",
            modifier = Modifier.padding(bottom = 180.dp),
            fontWeight = FontWeight.Bold
        )

        Text(text = initTime, modifier = Modifier.padding(top = 300.dp).width(400.dp))
        Text(text = provingTime, modifier = Modifier.padding(top = 350.dp).width(400.dp))
        Text(text = proofSize, modifier = Modifier.padding(top = 400.dp).width(400.dp))
        Text(text = valid, modifier = Modifier.padding(top = 450.dp).width(400.dp))
        Text(text = verifyingTime, modifier = Modifier.padding(top = 500.dp).width(400.dp))
    }
}
package probe.kotlin

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

/**
 * 探针 Activity。
 *
 * 这段代码存在的唯一目的：强制触发 Kotlin 编译器 + Compose 编译器插件
 * 的完整工作流。只要它能编过，说明：
 *   · kotlin compiler embeddable 链完整
 *   · compose compiler plugin 已就位（@Composable 才会被处理）
 *   · material3 / foundation / runtime 的元数据可读
 * 任何一环缺失都会在这里编译失败，而不是等用户拿到包才发现。
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { ProbeScreen() }
    }
}

@Composable
private fun ProbeScreen() {
    // 用真正的 state + lambda，确保 compose 的合成与快照系统都被走到
    var n by remember { mutableIntStateOf(0) }
    MaterialTheme {
        Column(Modifier.padding(24.dp)) {
            Text("AgentPad toolchain probe", style = MaterialTheme.typography.headlineSmall)
            Text("count = $n", style = MaterialTheme.typography.bodyLarge)
            Button(onClick = { n++ }) { Text("increment") }
        }
    }
}
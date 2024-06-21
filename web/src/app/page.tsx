"use client";
import Prove from "./prove";
import Footer from "./footer";

export default function Home() {
    return (
        <>
            <main className="min-h-screen flex-col items-center justify-between p-10 break-words dark:text-slate-400 text-slate-500">
                <h1 className="text-4xl font-bold mb-8">
                    Mopro Website Prover Tests
                </h1>

                <Prove circuit="complex-circuit-100k-100k"></Prove>
                <Prove circuit="complex-circuit-400k-400k"></Prove>
                <Prove circuit="complex-circuit-1000k-1000k"></Prove>
                <Prove circuit="complex-circuit-1600k-1600k"></Prove>
                {/* <Prove circuit="multiplier2"></Prove> */}
                {/* <Prove circuit="keccak256_256_test"></Prove> */}
                <div className="p-20"></div>
            </main>
            <Footer></Footer>
        </>
    );
}
